using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_NewSpecialisations : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            EnsureSpecialisationUniqueKey();
            PopulateFilterProgrammes();
            UpdateTotalCount();
            // Sync per-page dropdown to current grid page size
            int current = gvMain.SettingsPager.PageSize;
            System.Web.UI.WebControls.ListItem li = ddlPageSize.Items.FindByValue(current.ToString());
            if (li != null) li.Selected = true;
        }
    }

    /// <summary>
    /// Ensures the acad_programmecourses unique key includes specialisation_id.
    /// Without this, each course can only exist once per programme — so setting courses
    /// for one specialisation would steal/delete them from another. The correct key allows
    /// each specialisation to have its own copy of a course.
    /// </summary>
    private void EnsureSpecialisationUniqueKey()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // Check if specialisation_id is already part of the unique key.
                // Look for ANY unique index on this table that includes course_code but NOT specialisation_id.
                bool needsMigration = false;
                string indexName = "";

                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT s.INDEX_NAME 
                      FROM information_schema.STATISTICS s
                      WHERE s.TABLE_SCHEMA = DATABASE()
                        AND s.TABLE_NAME = 'acad_programmecourses'
                        AND s.NON_UNIQUE = 0
                        AND s.COLUMN_NAME = 'course_code'
                        AND s.INDEX_NAME != 'PRIMARY'
                      LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        indexName = result.ToString();
                        
                        // Check if this index already includes specialisation_id
                        using (MySqlCommand checkCmd = new MySqlCommand(
                            @"SELECT COUNT(*) FROM information_schema.STATISTICS 
                              WHERE TABLE_SCHEMA = DATABASE()
                                AND TABLE_NAME = 'acad_programmecourses' 
                                AND INDEX_NAME = @idx 
                                AND COLUMN_NAME = 'specialisation_id'", conn))
                        {
                            checkCmd.Parameters.AddWithValue("@idx", indexName);
                            int hasSpecCol = Convert.ToInt32(checkCmd.ExecuteScalar());
                            needsMigration = (hasSpecCol == 0);
                        }
                    }
                }

                if (needsMigration && !string.IsNullOrEmpty(indexName))
                {
                    // First, remove any exact duplicates that would block the new unique index.
                    // Keep only the row with the highest ID for each (course_code, progcode, CurriculumID, specialisation_id) combo.
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"DELETE t1 FROM acad_programmecourses t1
                          INNER JOIN acad_programmecourses t2
                          ON  t1.course_code = t2.course_code
                          AND t1.progcode = t2.progcode
                          AND t1.CurriculumID = t2.CurriculumID
                          AND (t1.specialisation_id = t2.specialisation_id 
                               OR (t1.specialisation_id IS NULL AND t2.specialisation_id IS NULL))
                          AND t1.ID < t2.ID", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Drop the old index
                    using (MySqlCommand cmd = new MySqlCommand(
                        string.Format("ALTER TABLE acad_programmecourses DROP INDEX `{0}`", indexName), conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Create new unique index that includes specialisation_id
                    using (MySqlCommand cmd = new MySqlCommand(
                        string.Format("ALTER TABLE acad_programmecourses ADD UNIQUE INDEX `{0}` (course_code, progcode, CurriculumID, specialisation_id)", indexName), conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
        }
        catch { /* Already migrated or table structure differs — safe to ignore */ }
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvMain.AddNewRow();
    }

    protected void gvMain_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
    }

    protected void gvMain_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
    }

    protected void gvMain_HtmlRowCreated(object sender, ASPxGridViewTableRowEventArgs e)
    {
        if (e.RowType == GridViewRowType.Data)
        {
            object val = gvMain.GetRowValues(e.VisibleIndex, "is_active");
            if (val != null && val.ToString() == "Inactive")
            {
                e.Row.CssClass = (e.Row.CssClass + " row-inactive").Trim();
            }
        }
    }

    protected void gvMain_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int specId = Convert.ToInt32(e.Keys["spec_id"]);
        int courseCount = GetCourseCountForSpec(specId);
        if (courseCount > 0)
        {
            e.Cancel = true;
            throw new Exception("Cannot delete specialisation with " + courseCount + " courses. Please remove or reassign courses first.");
        }
    }

    protected void gvMain_CustomErrorText(object sender, ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.Exception != null)
        {
            e.ErrorText = e.Exception.Message;
        }
    }

    #region Batch Operations (Main Grid)

    protected void btnBatchExecute_Click(object sender, EventArgs e)
    {
        string idsRaw = hdnBatchIds.Value;
        string action = (hdnBatchAction.Value ?? "").Trim();
        hdnBatchIds.Value = "";
        hdnBatchAction.Value = "";

        List<int> ids = ParseBatchIds(idsRaw);
        if (ids.Count == 0)
        {
            ShowBatchResult("err", "No valid rows were selected.");
            return;
        }

        switch (action)
        {
            case "fully_set_yes": BatchSetFullySet(ids, "Yes");   break;
            case "fully_set_no":  BatchSetFullySet(ids, "No");    break;
            case "set_active":    BatchSetActive(ids, "Active");   break;
            case "set_inactive":  BatchSetActive(ids, "Inactive"); break;
            case "delete":        BatchDelete(ids);                break;
            case "print_pdf":     BatchPrintPDF(ids);            return; // opens new tab, no result panel needed
            case "export_csv":    BatchExportCSV(ids);           return; // file download response
            default:
                ShowBatchResult("err", "Unknown action: " + action);
                break;
        }

        gvMain.DataBind();
        UpdateTotalCount();
    }

    private List<int> ParseBatchIds(string raw)
    {
        var list = new List<int>();
        if (string.IsNullOrEmpty(raw)) return list;
        foreach (string s in raw.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
        {
            int id;
            if (int.TryParse(s.Trim(), out id) && id > 0) list.Add(id);
        }
        return list;
    }

    private void BatchSetFullySet(List<int> ids, string value)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "UPDATE acad_specialisation SET is_fully_set = @v WHERE spec_id IN (" + string.Join(",", ids) + ")", conn))
            {
                cmd.Parameters.AddWithValue("@v", value);
                cmd.ExecuteNonQuery();
            }
        }
        string label = value == "Yes" ? "Fully Configured &#10003;" : "Not Fully Configured &#10007;";
        ShowBatchResult("ok", "<strong>" + ids.Count + "</strong> specialisation(s) marked as <strong>" + label + "</strong>.");
    }

    private void BatchSetActive(List<int> ids, string value)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "UPDATE acad_specialisation SET is_active = @v WHERE spec_id IN (" + string.Join(",", ids) + ")", conn))
            {
                cmd.Parameters.AddWithValue("@v", value);
                cmd.ExecuteNonQuery();
            }
        }
        string badge = value == "Active"
            ? "<span class='status-badge status-active'>&#9679; Active</span>"
            : "<span class='status-badge status-inactive'>&#9679; Inactive</span>";
        ShowBatchResult("ok", "<strong>" + ids.Count + "</strong> specialisation(s) set to " + badge + ".");
    }

    private void BatchDelete(List<int> ids)
    {
        int deleted = 0, skipped = 0;
        var skippedNames = new List<string>();

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            foreach (int id in ids)
            {
                int cnt;
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @id", conn))
                {
                    chk.Parameters.AddWithValue("@id", id);
                    cnt = Convert.ToInt32(chk.ExecuteScalar());
                }

                if (cnt > 0)
                {
                    string nm = id.ToString();
                    using (MySqlCommand nm_cmd = new MySqlCommand(
                        "SELECT spec FROM acad_specialisation WHERE spec_id = @id", conn))
                    {
                        nm_cmd.Parameters.AddWithValue("@id", id);
                        object r = nm_cmd.ExecuteScalar();
                        if (r != null) nm = r.ToString();
                    }
                    skippedNames.Add(nm + " (" + cnt + " courses)");
                    skipped++;
                }
                else
                {
                    using (MySqlCommand del = new MySqlCommand(
                        "DELETE FROM acad_specialisation WHERE spec_id = @id", conn))
                    {
                        del.Parameters.AddWithValue("@id", id);
                        del.ExecuteNonQuery();
                    }
                    deleted++;
                }
            }
        }

        var msg = new StringBuilder();
        string type = "ok";
        if (deleted > 0) msg.Append("<strong>" + deleted + "</strong> specialisation(s) deleted. ");
        if (skipped > 0)
        {
            type = deleted == 0 ? "err" : "inf";
            msg.Append("<strong>" + skipped + "</strong> skipped (have courses): " + string.Join("; ", skippedNames) + ".");
        }
        ShowBatchResult(type, msg.ToString());
    }

    private void BatchPrintPDF(List<int> ids)
    {
        // Open batch PDF in new tab — SpecialisationStructurePDF.aspx handles batchIds param
        string url = "SpecialisationStructurePDF.aspx?batchIds=" + string.Join(",", ids);
        ScriptManager.RegisterStartupScript(this, GetType(), "batchPdf",
            "window.open('" + url + "', '_blank');", true);
        ShowBatchResult("inf", "Opening PDF for <strong>" + ids.Count + "</strong> specialisation(s) in a new tab...");
        gvMain.DataBind();
        UpdateTotalCount();
    }

    private void BatchExportCSV(List<int> ids)
    {
        var csv = new StringBuilder();
        csv.AppendLine("ID,Programme,Specialisation,Abbreviation,Fully Set,Status,Course Count");

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = @"SELECT s.spec_id,
                               COALESCE(p.progname, s.prog_id) AS prog,
                               s.spec, s.abbrev, s.is_fully_set, s.is_active,
                               COALESCE(c.cnt, 0) AS cnt
                           FROM acad_specialisation s
                           LEFT JOIN acad_programme p ON s.prog_id = p.progcode
                           LEFT JOIN (SELECT specialisation_id, COUNT(*) cnt
                                      FROM acad_programmecourses
                                      GROUP BY specialisation_id) c
                                  ON s.spec_id = c.specialisation_id
                           WHERE s.spec_id IN (" + string.Join(",", ids) + @")
                           ORDER BY p.progname, s.spec";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataReader r = cmd.ExecuteReader())
            {
                while (r.Read())
                {
                    csv.AppendLine(string.Format("{0},\"{1}\",\"{2}\",{3},{4},{5},{6}",
                        r["spec_id"],
                        r["prog"].ToString().Replace("\"", "\"\""),
                        r["spec"].ToString().Replace("\"", "\"\""),
                        r["abbrev"],
                        r["is_fully_set"],
                        r["is_active"],
                        r["cnt"]));
                }
            }
        }

        Response.Clear();
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=\"specialisations_export.csv\"");
        Response.Write(csv.ToString());
        Response.End();
    }

    private void ShowBatchResult(string type, string message)
    {
        pnlBatchResult.Visible = true;

        string icon;
        string css;
        if (type == "ok")
        {
            icon = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:6px;flex-shrink:0'><polyline points='20 6 9 17 4 12'></polyline></svg>";
            css  = "padding:7px 14px;font-size:11px;border-left:4px solid #28a745;background:#d4edda;color:#155724;display:flex;align-items:center;";
        }
        else if (type == "err")
        {
            icon = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:6px;flex-shrink:0'><circle cx='12' cy='12' r='10'></circle><line x1='15' y1='9' x2='9' y2='15'></line><line x1='9' y1='9' x2='15' y2='15'></line></svg>";
            css  = "padding:7px 14px;font-size:11px;border-left:4px solid #dc3545;background:#f8d7da;color:#721c24;display:flex;align-items:center;";
        }
        else // inf
        {
            icon = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:6px;flex-shrink:0'><circle cx='12' cy='12' r='10'></circle><line x1='12' y1='8' x2='12' y2='12'></line><line x1='12' y1='16' x2='12.01' y2='16'></line></svg>";
            css  = "padding:7px 14px;font-size:11px;border-left:4px solid #007bff;background:#cce5ff;color:#004085;display:flex;align-items:center;";
        }

        pnlBatchResult.Attributes["style"] = css;
        lblBatchResult.Text = icon + message;
    }

    #endregion

    private void UpdateTotalCount()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT COUNT(*) FROM acad_specialisation";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalCount.Text = count.ToString();
                }
            }
        }
        catch (Exception)
        {
            lblTotalCount.Text = "0";
        }
    }

    #region Filter Bar

    private void PopulateFilterProgrammes()
    {
        ddlFilterProgramme.Items.Clear();
        ddlFilterProgramme.Items.Add(new System.Web.UI.WebControls.ListItem("All Programmes", ""));
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT DISTINCT p.progcode, p.progname
                        FROM acad_specialisation s
                        JOIN acad_programme p ON s.prog_id = p.progcode
                        ORDER BY p.progname", conn))
                using (MySqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                        ddlFilterProgramme.Items.Add(
                            new System.Web.UI.WebControls.ListItem(r["progname"].ToString(), r["progcode"].ToString()));
                }
            }
        }
        catch { /* silently skip if table unavailable */ }
    }

    private void ApplyFilters()
    {
        string search = (txtFilterSearch.Text ?? "").Trim();
        string prog   = ddlFilterProgramme.SelectedValue ?? "";
        string fully  = ddlFilterFullySet.SelectedValue  ?? "";
        string status = ddlFilterStatus.SelectedValue    ?? "";

        // Build DevExpress FilterExpression (CriteriaLanguage syntax)
        var parts = new List<string>();
        if (!string.IsNullOrEmpty(search))
        {
            string safe = search.Replace("'", "''");
            parts.Add(string.Format("(Contains([spec], '{0}') Or Contains([abbrev], '{0}'))", safe));
        }
        if (!string.IsNullOrEmpty(prog))
            parts.Add(string.Format("[prog_id] = '{0}'", prog.Replace("'", "''")));
        if (!string.IsNullOrEmpty(fully))
            parts.Add(string.Format("[is_fully_set] = '{0}'", fully));
        if (!string.IsNullOrEmpty(status))
            parts.Add(string.Format("[is_active] = '{0}'", status));

        gvMain.FilterExpression = parts.Count > 0 ? string.Join(" And ", parts) : "";

        bool active = parts.Count > 0;
        btnClearFilters.Visible  = active;
        pnlFilterChips.Visible   = active;
        pnlFilterBar.CssClass    = active ? "sfilter-bar bar-filtered" : "sfilter-bar";

        if (active)
        {
            // Build filter chip descriptions
            var chips = new StringBuilder();
            if (!string.IsNullOrEmpty(search))
                chips.Append("<span class='sfchip'>")  
                     .Append("<svg xmlns='http://www.w3.org/2000/svg' width='9' height='9' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><circle cx='11' cy='11' r='8'></circle><line x1='21' y1='21' x2='16.65' y2='16.65'></line></svg>")
                     .Append(" &ldquo;" + Server.HtmlEncode(search) + "&rdquo;</span> ");
            if (!string.IsNullOrEmpty(prog))
            {
                var li = ddlFilterProgramme.Items.FindByValue(prog);
                chips.Append("<span class='sfchip'>" + Server.HtmlEncode(li != null ? li.Text : prog) + "</span> ");
            }
            if (!string.IsNullOrEmpty(fully))
                chips.Append("<span class='sfchip'>Fully Set: " + Server.HtmlEncode(fully) + "</span> ");
            if (!string.IsNullOrEmpty(status))
                chips.Append("<span class='sfchip'>Status: " + Server.HtmlEncode(status) + "</span> ");
            litFilterChips.Text = chips.ToString();

            // Run filtered count
            int cnt = GetFilteredCount(search, prog, fully, status);
            lblFilteredCount.Text = "<strong>" + cnt + "</strong> result" + (cnt == 1 ? "" : "s") + " found";
            lblFilterInfo.Text    = "Showing " + cnt + " filtered result" + (cnt == 1 ? "" : "s");
        }
        else
        {
            lblFilterInfo.Text = "";
        }
    }

    private int GetFilteredCount(string search, string prog, string fully, string status)
    {
        var where = new List<string>();
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(search))
        {
            where.Add("(s.spec LIKE @search OR s.abbrev LIKE @search)");
            parms.Add(new MySqlParameter("@search", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(prog))
        {
            where.Add("s.prog_id = @prog");
            parms.Add(new MySqlParameter("@prog", prog));
        }
        if (!string.IsNullOrEmpty(fully))
        {
            where.Add("s.is_fully_set = @fs");
            parms.Add(new MySqlParameter("@fs", fully));
        }
        if (!string.IsNullOrEmpty(status))
        {
            where.Add("s.is_active = @sta");
            parms.Add(new MySqlParameter("@sta", status));
        }

        string sql = "SELECT COUNT(*) FROM acad_specialisation s" +
            (where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "");

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                foreach (var p in parms) cmd.Parameters.Add(p);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    protected void ddlFilter_Changed(object sender, EventArgs e)
    {
        gvMain.PageIndex = 0;
        ApplyFilters();
        UpdateTotalCount();
    }

    protected void btnApplySearch_Click(object sender, EventArgs e)
    {
        gvMain.PageIndex = 0;
        ApplyFilters();
        UpdateTotalCount();
    }

    protected void btnClearFilters_Click(object sender, EventArgs e)
    {
        txtFilterSearch.Text             = "";
        ddlFilterProgramme.SelectedIndex = 0;
        ddlFilterFullySet.SelectedIndex  = 0;
        ddlFilterStatus.SelectedIndex    = 0;
        gvMain.FilterExpression          = "";
        gvMain.PageIndex                 = 0;
        pnlFilterBar.CssClass            = "sfilter-bar";
        pnlFilterChips.Visible           = false;
        btnClearFilters.Visible          = false;
        lblFilterInfo.Text               = "";
        UpdateTotalCount();
    }

    protected void ddlPageSize_Changed(object sender, EventArgs e)
    {
        int size;
        if (int.TryParse(ddlPageSize.SelectedValue, out size))
        {
            // 0 means "All" — DevExpress uses a very large number to show all rows
            gvMain.SettingsPager.PageSize = size > 0 ? size : 999999;
            gvMain.PageIndex = 0;
            gvMain.DataBind();
        }
    }

    #endregion

    private int GetCourseCountForSpec(int specId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId", conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    protected void btnOpenManage_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSelectedSpecId.Value);
        OpenManageCoursesPopup(specId);
    }

    private void OpenManageCoursesPopup(int specId)
    {
        // Fetch specialisation details from database to ensure correct data
        string specName = "";
        string progCode = "";
        string progName = "";
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(@"SELECT s.spec, s.prog_id, p.progname 
                FROM acad_specialisation s 
                LEFT JOIN acad_programme p ON s.prog_id = p.progcode 
                WHERE s.spec_id = @specId", conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        specName = reader["spec"] != DBNull.Value ? reader["spec"].ToString() : "";
                        progCode = reader["prog_id"] != DBNull.Value ? reader["prog_id"].ToString() : "";
                        progName = reader["progname"] != DBNull.Value ? reader["progname"].ToString() : progCode;
                    }
                }
            }
        }
        
        hdnSpecId.Value = specId.ToString();
        hdnProgCode.Value = progCode;
        
        // Set both literal and label to ensure visibility
        litSpecName.Text = specName;
        litProgName.Text = progName;
        lblSpecName.Text = specName;
        lblProgName.Text = progName;
        
        // Debug output
        System.Diagnostics.Debug.WriteLine(string.Format("Setting labels - specName: '{0}', progName: '{1}', progCode: '{2}'", specName, progName, progCode));
        
        // Set context labels for Copy from Transcript tab - ensure they display
        lblContextSpecName.Text = !string.IsNullOrEmpty(specName) ? specName : "N/A";
        lblContextProgName.Text = !string.IsNullOrEmpty(progName) ? progName + " (" + progCode + ")" : progCode;
        
        // Debug: Force label visibility and ensure text is set
        lblSpecName.Visible = true;
        lblProgName.Visible = true;
        lblContextSpecName.Visible = true;
        lblContextProgName.Visible = true;
        
        // Force label to render with inline text if still not showing
        if (string.IsNullOrEmpty(lblSpecName.Text)) lblSpecName.Text = "[No Spec Name]";
        if (string.IsNullOrEmpty(lblProgName.Text)) lblProgName.Text = "[No Prog Name]";
        
        // Reset transcript tab
        txtTranscriptRegNo.Text = "";
        pnlTranscriptStudentInfo.Visible = false;
        pnlProgramMismatch.Visible = false;
        pnlTranscriptCourseList.Visible = false;
        pnlTranscriptSummary.Visible = false;
        pnlTranscriptActions.Visible = false;
        pnlTranscriptResult.Visible = false;
        
        // Reset batch add form - clear all year-semester fields
        txtY1S1.Text = ""; txtY1S2.Text = ""; txtY1S3.Text = "";
        txtY2S1.Text = ""; txtY2S2.Text = ""; txtY2S3.Text = "";
        txtY3S1.Text = ""; txtY3S2.Text = ""; txtY3S3.Text = "";
        txtY4S1.Text = ""; txtY4S2.Text = ""; txtY4S3.Text = "";
        pnlBatchSummary.Visible = false;
        pnlStructureDeleteResult.Visible = false;
        ddlSetFullySet.SelectedValue = "No";
        rblTranscriptFullySet.SelectedValue = "Yes";
        rblTranscriptIsActive.SelectedValue = "Active";
        
        // Load course structure
        LoadCourseStructure(specId);
        
        // Load courses grid
        LoadSpecCoursesGrid(specId);
        
        popManageCourses.ShowOnPageLoad = true;
        
        // Register script to show popup after page loads with data
        ScriptManager.RegisterStartupScript(this, GetType(), "ShowPopup", 
            "setTimeout(function(){ if(popManageCourses) popManageCourses.Show(); }, 100);", true);
    }

    // Helper class to store year-semester data
    private class YearSemesterData
    {
        public int Year { get; set; }
        public int Semester { get; set; }
        public string Courses { get; set; }
        public int Credits { get; set; }
        public string CourseType { get; set; }
        public TextBox CoursesControl { get; set; }
        public Panel ResultPanel { get; set; }
    }

    private List<YearSemesterData> GetAllYearSemesterData()
    {
        return new List<YearSemesterData>
        {
            new YearSemesterData { Year = 1, Semester = 1, Courses = txtY1S1.Text.Trim(), Credits = ParseCredits(txtY1S1CU.Text), CourseType = ddlY1S1Type.SelectedValue, CoursesControl = txtY1S1, ResultPanel = pnlY1S1Result },
            new YearSemesterData { Year = 1, Semester = 2, Courses = txtY1S2.Text.Trim(), Credits = ParseCredits(txtY1S2CU.Text), CourseType = ddlY1S2Type.SelectedValue, CoursesControl = txtY1S2, ResultPanel = pnlY1S2Result },
            new YearSemesterData { Year = 1, Semester = 3, Courses = txtY1S3.Text.Trim(), Credits = ParseCredits(txtY1S3CU.Text), CourseType = ddlY1S3Type.SelectedValue, CoursesControl = txtY1S3, ResultPanel = pnlY1S3Result },
            new YearSemesterData { Year = 2, Semester = 1, Courses = txtY2S1.Text.Trim(), Credits = ParseCredits(txtY2S1CU.Text), CourseType = ddlY2S1Type.SelectedValue, CoursesControl = txtY2S1, ResultPanel = pnlY2S1Result },
            new YearSemesterData { Year = 2, Semester = 2, Courses = txtY2S2.Text.Trim(), Credits = ParseCredits(txtY2S2CU.Text), CourseType = ddlY2S2Type.SelectedValue, CoursesControl = txtY2S2, ResultPanel = pnlY2S2Result },
            new YearSemesterData { Year = 2, Semester = 3, Courses = txtY2S3.Text.Trim(), Credits = ParseCredits(txtY2S3CU.Text), CourseType = ddlY2S3Type.SelectedValue, CoursesControl = txtY2S3, ResultPanel = pnlY2S3Result },
            new YearSemesterData { Year = 3, Semester = 1, Courses = txtY3S1.Text.Trim(), Credits = ParseCredits(txtY3S1CU.Text), CourseType = ddlY3S1Type.SelectedValue, CoursesControl = txtY3S1, ResultPanel = pnlY3S1Result },
            new YearSemesterData { Year = 3, Semester = 2, Courses = txtY3S2.Text.Trim(), Credits = ParseCredits(txtY3S2CU.Text), CourseType = ddlY3S2Type.SelectedValue, CoursesControl = txtY3S2, ResultPanel = pnlY3S2Result },
            new YearSemesterData { Year = 3, Semester = 3, Courses = txtY3S3.Text.Trim(), Credits = ParseCredits(txtY3S3CU.Text), CourseType = ddlY3S3Type.SelectedValue, CoursesControl = txtY3S3, ResultPanel = pnlY3S3Result },
            new YearSemesterData { Year = 4, Semester = 1, Courses = txtY4S1.Text.Trim(), Credits = ParseCredits(txtY4S1CU.Text), CourseType = ddlY4S1Type.SelectedValue, CoursesControl = txtY4S1, ResultPanel = pnlY4S1Result },
            new YearSemesterData { Year = 4, Semester = 2, Courses = txtY4S2.Text.Trim(), Credits = ParseCredits(txtY4S2CU.Text), CourseType = ddlY4S2Type.SelectedValue, CoursesControl = txtY4S2, ResultPanel = pnlY4S2Result },
            new YearSemesterData { Year = 4, Semester = 3, Courses = txtY4S3.Text.Trim(), Credits = ParseCredits(txtY4S3CU.Text), CourseType = ddlY4S3Type.SelectedValue, CoursesControl = txtY4S3, ResultPanel = pnlY4S3Result }
        };
    }

    private int ParseCredits(string text)
    {
        int credits;
        return int.TryParse(text, out credits) ? credits : 3;
    }

    protected void cmdValidateAll_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        var allData = GetAllYearSemesterData();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (var data in allData)
            {
                ValidateYearSemester(conn, specId, data);
            }
        }
        
        popManageCourses.ShowOnPageLoad = true;
    }

    private void ValidateYearSemester(MySqlConnection conn, int specId, YearSemesterData data)
    {
        // Clear previous result
        data.ResultPanel.Controls.Clear();
        data.ResultPanel.CssClass = "batch-validation-result";
        
        // Skip empty fields
        if (string.IsNullOrEmpty(data.Courses))
        {
            return;
        }
        
        // Split only by comma - preserve spaces inside course codes
        string[] codes = data.Courses.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        List<string> validCourses = new List<string>();
        List<string> invalidCourses = new List<string>();
        List<string> duplicateCourses = new List<string>();
        
        foreach (string code in codes)
        {
            string trimmedCode = code.Trim().ToUpper();
            if (string.IsNullOrEmpty(trimmedCode)) continue;
            
            // Check if course exists
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE courseID = @code", conn))
            {
                cmd.Parameters.AddWithValue("@code", trimmedCode);
                int exists = Convert.ToInt32(cmd.ExecuteScalar());
                
                if (exists == 0)
                {
                    invalidCourses.Add(trimmedCode);
                    continue;
                }
            }
            
            // Check if already added to this specialisation (any year/semester)
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId AND course_code = @code", conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                cmd.Parameters.AddWithValue("@code", trimmedCode);
                int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                
                if (duplicate > 0)
                {
                    duplicateCourses.Add(trimmedCode);
                    continue;
                }
            }
            
            validCourses.Add(trimmedCode);
        }
        
        // Build result message
        StringBuilder sb = new StringBuilder();
        string resultClass = "batch-validation-result has-result ";
        
        if (invalidCourses.Count == 0 && duplicateCourses.Count == 0 && validCourses.Count > 0)
        {
            resultClass += "valid";
            sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:3px;'><polyline points='20 6 9 17 4 12'></polyline></svg> " + validCourses.Count + " valid: " + string.Join(", ", validCourses));
        }
        else if (validCourses.Count == 0 && (invalidCourses.Count > 0 || duplicateCourses.Count > 0))
        {
            resultClass += "invalid";
            if (invalidCourses.Count > 0) sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:3px;'><circle cx='12' cy='12' r='10'></circle><line x1='15' y1='9' x2='9' y2='15'></line><line x1='9' y1='9' x2='15' y2='15'></line></svg> Invalid: " + string.Join(", ", invalidCourses) + " ");
            if (duplicateCourses.Count > 0) sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:3px;'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'></path><line x1='12' y1='9' x2='12' y2='13'></line><line x1='12' y1='17' x2='12.01' y2='17'></line></svg> Exists: " + string.Join(", ", duplicateCourses));
        }
        else
        {
            resultClass += "mixed";
            if (validCourses.Count > 0) sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='#155724' stroke-width='3' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:2px;'><polyline points='20 6 9 17 4 12'></polyline></svg> " + validCourses.Count + " valid ");
            if (invalidCourses.Count > 0) sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='#dc3545' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:2px;'><circle cx='12' cy='12' r='10'></circle><line x1='15' y1='9' x2='9' y2='15'></line><line x1='9' y1='9' x2='15' y2='15'></line></svg> " + invalidCourses.Count + " invalid ");
            if (duplicateCourses.Count > 0) sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='#856404' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:2px;'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'></path><line x1='12' y1='9' x2='12' y2='13'></line><line x1='12' y1='17' x2='12.01' y2='17'></line></svg> " + duplicateCourses.Count + " exist");
        }
        
        data.ResultPanel.CssClass = resultClass;
        data.ResultPanel.Controls.Add(new LiteralControl(sb.ToString()));
    }

    protected void cmdAddAllBatch_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        string progCode = hdnProgCode.Value;
        var allData = GetAllYearSemesterData();
        
        int totalAdded = 0;
        int totalSkipped = 0;
        int totalInvalid = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (var data in allData)
            {
                // Skip empty fields
                if (string.IsNullOrEmpty(data.Courses)) continue;
                
                // Split only by comma - preserve spaces inside course codes
                string[] codes = data.Courses.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                
                foreach (string code in codes)
                {
                    string trimmedCode = code.Trim().ToUpper();
                    if (string.IsNullOrEmpty(trimmedCode)) continue;
                    
                    // Check if course exists in acad_course table
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE courseID = @code", conn))
                    {
                        cmd.Parameters.AddWithValue("@code", trimmedCode);
                        int exists = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (exists == 0)
                        {
                            totalInvalid++;
                            continue;
                        }
                    }
                    
                    // ===================================================================
                    // Check duplicates PER SPECIALIZATION ONLY
                    // Courses can exist in multiple specializations - this is VALID
                    // Only prevent duplicate within SAME specialization
                    // ===================================================================
                    
                    // Check if course already exists in THIS specialization
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"SELECT COUNT(*) FROM acad_programmecourses 
                          WHERE specialisation_id = @specId 
                          AND TRIM(course_code) = @code 
                          AND CurriculumID = 0", conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", specId);
                        cmd.Parameters.AddWithValue("@code", trimmedCode);
                        int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (duplicate > 0)
                        {
                            totalSkipped++;
                            continue;
                        }
                    }
                    
                    // INSERT the course for THIS specialisation
                    // The unique key now includes specialisation_id, so the same course
                    // can correctly exist in multiple specialisations without conflict
                    try
                    {
                        using (MySqlCommand cmd = new MySqlCommand(
                            @"INSERT INTO acad_programmecourses 
                              (progcode, course_code, study_year, semester, CurriculumID, specialisation_id, course_type) 
                              VALUES (@progcode, @code, @year, @sem, 0, @specId, @courseType)", conn))
                        {
                            cmd.Parameters.AddWithValue("@progcode", progCode);
                            cmd.Parameters.AddWithValue("@code", trimmedCode);
                            cmd.Parameters.AddWithValue("@year", data.Year);
                            cmd.Parameters.AddWithValue("@sem", data.Semester);
                            cmd.Parameters.AddWithValue("@specId", specId);
                            cmd.Parameters.AddWithValue("@courseType", data.CourseType);
                            cmd.ExecuteNonQuery();
                        }
                        totalAdded++;
                        
                        // Update course credits if specified
                        if (data.Credits > 0)
                        {
                            using (MySqlCommand cuCmd = new MySqlCommand("UPDATE acad_course SET CreditUnit = @credits WHERE courseID = @code AND (CreditUnit IS NULL OR CreditUnit = 0)", conn))
                            {
                                cuCmd.Parameters.AddWithValue("@credits", data.Credits);
                                cuCmd.Parameters.AddWithValue("@code", trimmedCode);
                                cuCmd.ExecuteNonQuery();
                            }
                        }
                    }
                    catch (MySqlException ex)
                    {
                        // Duplicate entry — treat as skip (safety net if duplicate check missed due to CHAR padding)
                        if (ex.Number == 1062)
                            totalSkipped++;
                        else
                            throw;
                    }
                }
                
                // Clear the input field after processing
                data.CoursesControl.Text = "";
                data.ResultPanel.Controls.Clear();
                data.ResultPanel.CssClass = "batch-validation-result";
            }
            
            // Update is_fully_set if selected
            string fullySetValue = ddlSetFullySet.SelectedValue;
            if (fullySetValue == "Yes")
            {
                using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_specialisation SET is_fully_set = @value WHERE spec_id = @specId", conn))
                {
                    cmd.Parameters.AddWithValue("@value", fullySetValue);
                    cmd.Parameters.AddWithValue("@specId", specId);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        
        // Show summary
        StringBuilder summary = new StringBuilder();
        summary.Append("<strong>Batch Add Complete:</strong> ");
        summary.Append("<span style='color:#28a745'>Added: " + totalAdded + "</span>");
        if (totalSkipped > 0) summary.Append(" | <span style='color:#856404'>Skipped (duplicates): " + totalSkipped + "</span>");
        if (totalInvalid > 0) summary.Append(" | <span style='color:#dc3545'>Invalid: " + totalInvalid + "</span>");
        if (ddlSetFullySet.SelectedValue == "Yes") summary.Append(" | <span style='color:#174DA4'>Marked as Fully Set</span>");
        
        litBatchSummary.Text = summary.ToString();
        pnlBatchSummary.Visible = true;
        
        // Refresh structure and grid
        LoadCourseStructure(specId);
        LoadSpecCoursesGrid(specId);
        
        // Refresh main grid to update course counts
        gvMain.DataBind();
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void cmdRefreshStructure_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadCourseStructure(specId);
        popManageCourses.ShowOnPageLoad = true;
    }

    /// <summary>
    /// Batch delete selected courses from the Structure tab.
    /// IDs are collected client-side and placed in hdnDeleteIds before postback.
    /// Each ID is validated to belong to the current specialisation before deletion.
    /// </summary>
    protected void cmdDeleteSelectedCourses_Click(object sender, EventArgs e)
    {
        string idsRaw = hdnDeleteIds.Value;
        hdnDeleteIds.Value = ""; // clear so it doesn't re-trigger on refresh

        // Parse integer IDs only — reject anything that isn't a plain integer
        List<int> ids = new List<int>();
        if (!string.IsNullOrEmpty(idsRaw))
        {
            foreach (string raw in idsRaw.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                int id;
                if (int.TryParse(raw.Trim(), out id) && id > 0)
                    ids.Add(id);
            }
        }

        if (ids.Count == 0)
        {
            ShowStructureDeleteResult(false, "No valid courses were selected.");
            popManageCourses.ShowOnPageLoad = true;
            return;
        }

        int specId = Convert.ToInt32(hdnSpecId.Value);
        int deletedCount = 0;

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            foreach (int id in ids)
            {
                // Safety: only delete rows belonging to THIS specialisation
                using (MySqlCommand cmd = new MySqlCommand(
                    "DELETE FROM acad_programmecourses WHERE ID = @id AND specialisation_id = @specId", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@specId", specId);
                    deletedCount += cmd.ExecuteNonQuery();
                }
            }
        }

        if (deletedCount > 0)
            ShowStructureDeleteResult(true, deletedCount + " course" + (deletedCount == 1 ? "" : "s") + " deleted successfully.");
        else
            ShowStructureDeleteResult(false, "No courses were deleted. They may have already been removed.");

        // Refresh both views and main grid course count
        LoadCourseStructure(specId);
        LoadSpecCoursesGrid(specId);
        gvMain.DataBind();

        popManageCourses.ShowOnPageLoad = true;

        // Switch back to the Structure tab (index 2) after the postback
        ScriptManager.RegisterStartupScript(this, GetType(), "SwitchToStructureTab",
            "setTimeout(function(){ if(typeof tabCourses !== 'undefined') tabCourses.SetActiveTabIndex(2); }, 200);", true);
    }

    private void ShowStructureDeleteResult(bool success, string message)
    {
        pnlStructureDeleteResult.Visible = true;
        if (success)
        {
            pnlStructureDeleteResult.Style["border-left"] = "3px solid #28a745";
            pnlStructureDeleteResult.Style["background"] = "#d4edda";
            pnlStructureDeleteResult.Style["color"] = "#155724";
        }
        else
        {
            pnlStructureDeleteResult.Style["border-left"] = "3px solid #dc3545";
            pnlStructureDeleteResult.Style["background"] = "#f8d7da";
            pnlStructureDeleteResult.Style["color"] = "#721c24";
        }
        lblStructureDeleteResult.Text = message;
    }

    private void LoadCourseStructure(int specId)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='year-sem-table'>");
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Get max year
            int maxYear = 5;
            
            for (int year = 1; year <= maxYear; year++)
            {
                sb.Append("<tr><th colspan='2' class='year-sem-header'>Year " + year + "</th></tr>");
                
                for (int sem = 1; sem <= 2; sem++)
                {
                    sb.Append("<tr><th style='width:100px;'>Semester " + sem + "</th><td>");
                    
                    using (MySqlCommand cmd = new MySqlCommand(
                        "SELECT pc.ID, pc.course_code, c.courseName, c.CreditUnit " +
                        "FROM acad_programmecourses pc " +
                        "LEFT JOIN acad_course c ON pc.course_code = c.courseID " +
                        "WHERE pc.specialisation_id = @specId AND pc.study_year = @year AND pc.semester = @sem " +
                        "ORDER BY pc.course_code", conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", specId);
                        cmd.Parameters.AddWithValue("@year", year);
                        cmd.Parameters.AddWithValue("@sem", sem);
                        
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            bool hasCourses = false;
                            while (reader.Read())
                            {
                                hasCourses = true;
                                string rowId = reader["ID"].ToString();
                                string courseCode = reader["course_code"].ToString();
                                string courseName = reader["courseName"] != DBNull.Value ? reader["courseName"].ToString() : "";
                                string credits = reader["CreditUnit"] != DBNull.Value ? reader["CreditUnit"].ToString() : "0";
                                
                                sb.Append("<div class='course-item' data-row-id='" + rowId + "'>");
                                sb.Append("<input type='checkbox' class='struct-chk' data-id='" + rowId + "' onchange='onStructureCheckChange(this);' style='cursor:pointer;width:13px;height:13px;margin-right:5px;flex-shrink:0;vertical-align:middle;' />");
                                sb.Append("<span style='flex:1;'><strong>" + System.Web.HttpUtility.HtmlEncode(courseCode) + "</strong> " + System.Web.HttpUtility.HtmlEncode(courseName) + "</span>");
                                sb.Append("<span class='credits'>" + credits + " CU</span>");
                                sb.Append("</div>");
                            }
                            
                            if (!hasCourses)
                            {
                                sb.Append("<div style='color:#999;font-style:italic;font-size:11px;padding:8px;'>No courses assigned</div>");
                            }
                        }
                    }
                    
                    sb.Append("</td></tr>");
                }
            }
        }
        
        sb.Append("</table>");
        litCourseStructure.Text = sb.ToString();
    }

    private void LoadSpecCoursesGrid(int specId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT pc.ID, pc.course_code, pc.study_year, pc.semester, pc.course_type, c.courseName, c.CreditUnit " +
                        "FROM acad_programmecourses pc " +
                        "LEFT JOIN acad_course c ON pc.course_code = c.courseID " +
                        "WHERE pc.specialisation_id = @specId " +
                        "ORDER BY pc.study_year, pc.semester, pc.course_code";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSpecCourses.DataSource = dt;
                    gvSpecCourses.DataBind();
                    
                    // Update summary labels
                    int totalCount = dt.Rows.Count;
                    int coreCount = 0;
                    int electiveCount = 0;
                    int totalCredits = 0;
                    
                    foreach (DataRow row in dt.Rows)
                    {
                        string cType = row["course_type"] != DBNull.Value ? row["course_type"].ToString().Trim().ToUpper() : "";
                        int cu = row["CreditUnit"] != DBNull.Value ? Convert.ToInt32(row["CreditUnit"]) : 0;
                        
                        if (cType == "CORE")
                            coreCount++;
                        else
                            electiveCount++;
                        
                        totalCredits += cu;
                    }
                    
                    lblCoursesCount.Text = totalCount.ToString();
                    lblCoreCount.Text = coreCount.ToString();
                    lblElectiveCount.Text = electiveCount.ToString();
                    lblTotalCredits.Text = totalCredits.ToString();
                }
            }
        }
    }

    protected void cmdRefreshCourses_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadSpecCoursesGrid(specId);
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void gvSpecCourses_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        int year = Convert.ToInt32(e.NewValues["study_year"]);
        int semester = Convert.ToInt32(e.NewValues["semester"]);
        int credits = e.NewValues["CreditUnit"] != null ? Convert.ToInt32(e.NewValues["CreditUnit"]) : 0;
        string courseType = e.NewValues["course_type"] != null ? e.NewValues["course_type"].ToString() : "CORE";
        string courseCode = e.OldValues["course_code"].ToString();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            // Update programme course year/semester/course_type
            using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_programmecourses SET study_year = @year, semester = @sem, course_type = @courseType WHERE ID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@year", year);
                cmd.Parameters.AddWithValue("@sem", semester);
                cmd.Parameters.AddWithValue("@courseType", courseType);
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
            
            // Update course credits
            using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_course SET CreditUnit = @credits WHERE courseID = @code", conn))
            {
                cmd.Parameters.AddWithValue("@credits", credits);
                cmd.Parameters.AddWithValue("@code", courseCode);
                cmd.ExecuteNonQuery();
            }
        }
        
        e.Cancel = true;
        gvSpecCourses.CancelEdit();
        
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadSpecCoursesGrid(specId);
        LoadCourseStructure(specId);
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void gvSpecCourses_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("DELETE FROM acad_programmecourses WHERE ID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
        }
        
        e.Cancel = true;
        
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadSpecCoursesGrid(specId);
        LoadCourseStructure(specId);
        gvMain.DataBind();
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void cmdPrintStructure_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        string specName = lblSpecName.Text;
        string progName = lblProgName.Text;
        
        // Generate PDF - redirect to a PDF generation page
        string url = "SpecialisationStructurePDF.aspx?specId=" + specId + "&specName=" + Server.UrlEncode(specName) + "&progName=" + Server.UrlEncode(progName);
        ScriptManager.RegisterStartupScript(this, GetType(), "openPdf", "window.open('" + url + "', '_blank');", true);
        
        popManageCourses.ShowOnPageLoad = true;
    }

    #region Copy from Transcript Functionality
    
    // Helper class to store transcript course data
    [Serializable]
    private class TranscriptCourse
    {
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int Year { get; set; }
        public int Semester { get; set; }
        public int CreditUnits { get; set; }
        public string Grade { get; set; }
        public string Status { get; set; } // "Ready", "Already Exists", "Invalid Course", "Failed"
        public string StatusReason { get; set; }
    }

    /// <summary>
    /// Load student transcript and extract courses for potential import
    /// Created: February 6, 2026
    /// Purpose: Allow copying curriculum from a student's actual results
    /// </summary>
    protected void cmdLoadTranscript_Click(object sender, EventArgs e)
    {
        string searchTerm = txtTranscriptRegNo.Text.Trim().ToUpper();
        
        // Reset all panels
        pnlTranscriptStudentInfo.Visible = false;
        pnlProgramMismatch.Visible = false;
        pnlTranscriptCourseList.Visible = false;
        pnlTranscriptSummary.Visible = false;
        pnlTranscriptActions.Visible = false;
        pnlTranscriptResult.Visible = false;
        
        if (string.IsNullOrEmpty(searchTerm))
        {
            ShowTranscriptError("Please enter a student registration number or entry number.");
            return;
        }
        
        try
        {
            int specId = Convert.ToInt32(hdnSpecId.Value);
            string progCode = hdnProgCode.Value;
            string targetProgName = lblContextProgName.Text;
            
            List<TranscriptCourse> courses = new List<TranscriptCourse>();
            string studentName = "";
            string studentProg = "";
            string studentProgCode = "";
            string regno = "";
            int totalCourses = 0;
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Step 1: Validate student exists and get basic info (search by regno or entryno)
                string studentSql = @"SELECT 
                                        s.regno,
                                        CONCAT(TRIM(s.firstname), ' ', COALESCE(TRIM(s.othername), '')) AS fullname, 
                                        s.progid AS prog_code,
                                        COALESCE(p.progname, s.progid) AS programme
                                      FROM acad_student s
                                      LEFT JOIN acad_programme p ON s.progid = p.progcode
                                      WHERE TRIM(s.regno) = @searchTerm 
                                         OR TRIM(s.entryno) = @searchTerm
                                      LIMIT 1";
                
                using (MySqlCommand cmd = new MySqlCommand(studentSql, conn))
                {
                    cmd.Parameters.AddWithValue("@searchTerm", searchTerm);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            ShowTranscriptError("Student not found: " + searchTerm + "<br/>Please verify the registration number or entry number is correct.");
                            return;
                        }
                        regno = reader["regno"].ToString().Trim();
                        studentName = reader["fullname"].ToString().Trim();
                        studentProgCode = reader["prog_code"] != DBNull.Value ? reader["prog_code"].ToString().Trim() : "";
                        studentProg = reader["programme"].ToString().Trim();
                    }
                }
                
                // Step 2: Get all courses from student's transcript (passed courses only)
                string transcriptSql = @"SELECT DISTINCT
                                            TRIM(r.courseid) AS course_code,
                                            COALESCE(TRIM(c.courseName), TRIM(r.courseid)) AS course_name,
                                            r.studyyear AS year,
                                            r.semester,
                                            COALESCE(r.CreditUnits, c.CreditUnit, 3) AS credit_units,
                                            TRIM(r.grade) AS grade
                                         FROM acad_results r
                                         LEFT JOIN acad_course c ON TRIM(r.courseid) = TRIM(c.courseID)
                                         WHERE TRIM(r.regno) = @regno
                                           AND r.grade IS NOT NULL
                                           AND TRIM(r.grade) != ''
                                           AND TRIM(r.grade) != 'F'
                                           AND TRIM(r.grade) != 'NE'
                                           AND TRIM(r.grade) != 'NC'
                                         ORDER BY r.studyyear, r.semester, r.courseid";
                
                using (MySqlCommand cmd = new MySqlCommand(transcriptSql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            TranscriptCourse tc = new TranscriptCourse
                            {
                                CourseCode = reader["course_code"].ToString().Trim(),
                                CourseName = reader["course_name"].ToString().Trim(),
                                Year = Convert.ToInt32(reader["year"]),
                                Semester = Convert.ToInt32(reader["semester"]),
                                CreditUnits = Convert.ToInt32(reader["credit_units"]),
                                Grade = reader["grade"].ToString().Trim()
                            };
                            courses.Add(tc);
                            totalCourses++;
                        }
                    }
                }
                
                if (courses.Count == 0)
                {
                    ShowTranscriptError("No passed courses found in transcript for: " + regno);
                    return;
                }
                
                // Step 3: Validate each course against current specialisation
                // Track course codes seen in this batch to prevent duplicates within the transcript itself
                HashSet<string> seenCourseCodes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                
                foreach (var course in courses)
                {
                    // Check for duplicate within the transcript list itself
                    if (seenCourseCodes.Contains(course.CourseCode))
                    {
                        course.Status = "Already Exists";
                        course.StatusReason = "Duplicate in transcript (same course appears more than once)";
                        continue;
                    }
                    
                    // Check if course exists in acad_course table
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE TRIM(courseID) = @code", conn))
                    {
                        cmd.Parameters.AddWithValue("@code", course.CourseCode);
                        int exists = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (exists == 0)
                        {
                            course.Status = "Invalid Course";
                            course.StatusReason = "Not in course bank";
                            continue;
                        }
                    }
                    
                    // Check if course already exists in THIS specialisation
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"SELECT COUNT(*) FROM acad_programmecourses 
                          WHERE specialisation_id = @specId 
                          AND TRIM(course_code) = @code", conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", specId);
                        cmd.Parameters.AddWithValue("@code", course.CourseCode);
                        int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (duplicate > 0)
                        {
                            course.Status = "Already Exists";
                            course.StatusReason = "Already in this specialisation";
                            continue;
                        }
                    }
                    
                    // Course is not in this specialisation — mark ready
                    // (If it exists under another specialisation for the same programme,
                    //  the Apply step will reassign it to this specialisation.)
                    course.Status = "Ready";
                    course.StatusReason = "Will be added";
                    seenCourseCodes.Add(course.CourseCode);
                }
            }
            
            // Step 4: Store courses in Session for later use (avoid ViewState serialization issues)
            Session["TranscriptCourses"] = courses;
            Session["TranscriptRegNo"] = regno;
            
            // Step 5: Display results
            int readyCount = courses.Count(c => c.Status == "Ready");
            int existsCount = courses.Count(c => c.Status == "Already Exists");
            int invalidCount = courses.Count(c => c.Status == "Invalid Course");
            
            // Show student info
            lblTranscriptStudent.Text = studentName + " (" + regno + ")";
            lblTranscriptProgramme.Text = studentProg;
            lblTranscriptCourseCount.Text = totalCourses.ToString();
            
            if (readyCount > 0)
            {
                lblTranscriptValidation.Text = readyCount + " courses ready";
                lblTranscriptValidation.CssClass = "validation-success";
            }
            else
            {
                lblTranscriptValidation.Text = "No new courses";
                lblTranscriptValidation.CssClass = "validation-error";
            }
            
            pnlTranscriptStudentInfo.Visible = true;
            
            // Check for program mismatch and show warning
            if (!string.IsNullOrEmpty(studentProgCode) && !string.IsNullOrEmpty(progCode) && 
                !studentProgCode.Equals(progCode, StringComparison.OrdinalIgnoreCase))
            {
                pnlProgramMismatch.Visible = true;
                lblProgramMismatchDetails.Text = string.Format(
                    "Student is in <strong>{0}</strong> but you are copying to <strong>{1}</strong> specialisation. "+
                    "Courses may not match the target programme curriculum. Proceed with caution.",
                    studentProg, targetProgName);
            }
            
            // Bind courses to Repeater (more space efficient than GridView)
            rptTranscriptCourses.DataSource = courses;
            rptTranscriptCourses.DataBind();
            pnlTranscriptCourseList.Visible = true;
            
            // Show summary
            StringBuilder summary = new StringBuilder();
            summary.Append("<strong>Import Summary:</strong><br/>");
            summary.Append("• " + readyCount + " courses will be added<br/>");
            if (existsCount > 0) summary.Append("• " + existsCount + " courses already exist (will be skipped)<br/>");
            if (invalidCount > 0) summary.Append("• " + invalidCount + " invalid courses (will be skipped)<br/>");
            summary.Append("<br/><strong>Note:</strong> All courses will be added as CORE type. You can edit them later if needed.");
            
            litTranscriptSummary.Text = summary.ToString();
            pnlTranscriptSummary.Visible = true;
            
            // Show action buttons only if there are courses to import
            pnlTranscriptActions.Visible = (readyCount > 0);
            
        }
        catch (Exception ex)
        {
            ShowTranscriptError("Error loading transcript: " + ex.Message);
        }
    }

    /// <summary>
    /// Apply selected courses from transcript to current specialisation
    /// Created: February 6, 2026
    /// </summary>
    protected void cmdApplyTranscript_Click(object sender, EventArgs e)
    {
        try
        {
            List<TranscriptCourse> courses = Session["TranscriptCourses"] as List<TranscriptCourse>;
            if (courses == null || courses.Count == 0)
            {
                ShowTranscriptError("No courses to import. Please load transcript first.");
                return;
            }
            
            int specId = Convert.ToInt32(hdnSpecId.Value);
            string progCode = hdnProgCode.Value != null ? hdnProgCode.Value.Trim() : "";
            string regno = Session["TranscriptRegNo"] as string;
            
            int addedCount = 0;
            int skippedDuplicate = 0;
            int skippedError = 0;
            string lastError = "";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (var course in courses.Where(c => c.Status == "Ready"))
                {
                    string trimmedCode = course.CourseCode.Trim();
                    
                    try
                    {
                        // Check if course already exists in THIS specialisation (true duplicate)
                        int inThisSpec = 0;
                        using (MySqlCommand checkCmd = new MySqlCommand(
                            @"SELECT COUNT(*) FROM acad_programmecourses 
                              WHERE specialisation_id = @specId 
                              AND TRIM(course_code) = @code", conn))
                        {
                            checkCmd.Parameters.AddWithValue("@specId", specId);
                            checkCmd.Parameters.AddWithValue("@code", trimmedCode);
                            inThisSpec = Convert.ToInt32(checkCmd.ExecuteScalar());
                        }
                        
                        if (inThisSpec > 0)
                        {
                            skippedDuplicate++;
                            continue;
                        }
                        
                        // INSERT the course for THIS specialisation
                        // The unique key now includes specialisation_id, so the same course
                        // can correctly exist in multiple specialisations without conflict
                        using (MySqlCommand insertCmd = new MySqlCommand(
                            @"INSERT INTO acad_programmecourses 
                              (progcode, course_code, study_year, semester, CurriculumID, specialisation_id, course_type) 
                              VALUES (@progcode, @code, @year, @sem, 0, @specId, 'CORE')", conn))
                        {
                            insertCmd.Parameters.AddWithValue("@progcode", progCode);
                            insertCmd.Parameters.AddWithValue("@code", trimmedCode);
                            insertCmd.Parameters.AddWithValue("@year", course.Year);
                            insertCmd.Parameters.AddWithValue("@sem", course.Semester);
                            insertCmd.Parameters.AddWithValue("@specId", specId);
                            insertCmd.ExecuteNonQuery();
                            addedCount++;
                        }
                        
                        // Update course credit units if needed
                        if (course.CreditUnits > 0)
                        {
                            using (MySqlCommand updateCuCmd = new MySqlCommand(
                                @"UPDATE acad_course 
                                  SET CreditUnit = @credits 
                                  WHERE TRIM(courseID) = @code 
                                  AND (CreditUnit IS NULL OR CreditUnit = 0)", conn))
                            {
                                updateCuCmd.Parameters.AddWithValue("@credits", course.CreditUnits);
                                updateCuCmd.Parameters.AddWithValue("@code", trimmedCode);
                                updateCuCmd.ExecuteNonQuery();
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        skippedError++;
                        lastError = trimmedCode + ": " + ex.Message;
                    }
                }
            }
            
            // Update is_fully_set and is_active
            string transcriptFullySet = rblTranscriptFullySet.SelectedValue;
            string transcriptIsActive = rblTranscriptIsActive.SelectedValue;
            using (MySqlConnection conn2 = new MySqlConnection(ConnectionString))
            {
                conn2.Open();
                using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_specialisation SET is_fully_set = @fsValue, is_active = @iaValue WHERE spec_id = @specId", conn2))
                {
                    cmd.Parameters.AddWithValue("@fsValue", transcriptFullySet);
                    cmd.Parameters.AddWithValue("@iaValue", transcriptIsActive);
                    cmd.Parameters.AddWithValue("@specId", specId);
                    cmd.ExecuteNonQuery();
                }
            }
            
            // Clear transcript data
            Session["TranscriptCourses"] = null;
            Session["TranscriptRegNo"] = null;
            
            // Hide all panels except result
            pnlTranscriptStudentInfo.Visible = false;
            pnlTranscriptCourseList.Visible = false;
            pnlTranscriptSummary.Visible = false;
            pnlTranscriptActions.Visible = false;
            
            // Show success message
            int totalProcessed = addedCount;
            StringBuilder result = new StringBuilder();
            result.Append("<strong><svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='#28a745' stroke-width='3' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:4px;'><polyline points='20 6 9 17 4 12'></polyline></svg> Import Complete</strong><br/>");
            if (addedCount > 0) result.Append("• " + addedCount + " new courses added to specialisation<br/>");
            if (skippedDuplicate > 0) result.Append("• " + skippedDuplicate + " courses skipped (already in this specialisation)<br/>");
            if (skippedError > 0) result.Append("• " + skippedError + " courses failed (" + lastError + ")<br/>");
            if (totalProcessed == 0 && skippedDuplicate > 0) result.Append("<br/><em>All courses already exist in this specialisation.</em><br/>");
            result.Append("<br/>Source: Student " + regno + "'s transcript<br/>");
            if (totalProcessed > 0) result.Append("All courses added as CORE type. Review the 'Courses' tab to edit if needed.");
            result.Append("<br/><span style='color:#174DA4; font-weight:600;'><svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='#174DA4' stroke-width='3' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:3px;'><polyline points='20 6 9 17 4 12'></polyline></svg> Specialisation &mdash; Fully Configured: " + transcriptFullySet + " &bull; Status: " + transcriptIsActive + "</span>");
            
            litTranscriptResult.Text = result.ToString();
            pnlTranscriptResult.Visible = true;
            
            // Clear input field
            txtTranscriptRegNo.Text = "";
            
            // Refresh grids
            LoadSpecCoursesGrid(specId);
            LoadCourseStructure(specId);
            gvMain.DataBind();
        }
        catch (Exception ex)
        {
            ShowTranscriptError("Error applying courses: " + ex.Message);
        }
    }

    /// <summary>
    /// Cancel transcript import and reset form
    /// </summary>
    protected void cmdCancelTranscript_Click(object sender, EventArgs e)
    {
        // Clear ViewState
        Session["TranscriptCourses"] = null;
        Session["TranscriptRegNo"] = null;
        
        // Reset all panels
        pnlTranscriptStudentInfo.Visible = false;
        pnlTranscriptCourseList.Visible = false;
        pnlTranscriptSummary.Visible = false;
        pnlTranscriptActions.Visible = false;
        pnlTranscriptResult.Visible = false;
        rblTranscriptFullySet.SelectedValue = "Yes";
        rblTranscriptIsActive.SelectedValue = "Active";
        
        // Clear input
        txtTranscriptRegNo.Text = "";
    }
    
    /// <summary>
    /// Restore popup context labels after postback
    /// </summary>
    private void RestorePopupContext()
    {
        if (!string.IsNullOrEmpty(hdnSpecId.Value))
        {
            int specId = Convert.ToInt32(hdnSpecId.Value);
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(@"SELECT s.spec, s.prog_id, p.progname 
                    FROM acad_specialisation s 
                    LEFT JOIN acad_programme p ON s.prog_id = p.progcode 
                    WHERE s.spec_id = @specId", conn))
                {
                    cmd.Parameters.AddWithValue("@specId", specId);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string specName = reader["spec"] != DBNull.Value ? reader["spec"].ToString() : "";
                            string progCode = reader["prog_id"] != DBNull.Value ? reader["prog_id"].ToString() : "";
                            string progName = reader["progname"] != DBNull.Value ? reader["progname"].ToString() : progCode;
                            
                            // Update all labels
                            litSpecName.Text = specName;
                            litProgName.Text = progName;
                            lblSpecName.Text = specName;
                            lblProgName.Text = progName;
                            lblContextSpecName.Text = specName;
                            lblContextProgName.Text = progName + " (" + progCode + ")";
                            hdnProgCode.Value = progCode;
                        }
                    }
                }
            }
        }
    }

    /// <summary>
    /// Helper method to display error messages in transcript tab
    /// </summary>
    private void ShowTranscriptError(string message)
    {
        pnlTranscriptResult.Visible = true;
        pnlTranscriptResult.Style["border-left"] = "3px solid #dc3545";
        pnlTranscriptResult.Style["background"] = "#f8d7da";
        litTranscriptResult.Text = "<strong><svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='#dc3545' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' style='vertical-align:middle;margin-right:4px;'><circle cx='12' cy='12' r='10'></circle><line x1='15' y1='9' x2='9' y2='15'></line><line x1='9' y1='9' x2='15' y2='15'></line></svg> Error</strong><br/>" + message;
    }

    /// <summary>
    /// Helper method for status badge CSS class
    /// </summary>
    protected string GetStatusBadgeClass(string status)
    {
        switch (status)
        {
            case "Ready":
                return "ready";
            case "Already Exists":
                return "exists";
            case "Invalid Course":
                return "invalid";
            default:
                return "";
        }
    }

    /// <summary>
    /// Helper method for status badge text with inline SVG icon
    /// </summary>
    protected string GetStatusBadgeText(string status)
    {
        switch (status)
        {
            case "Ready":
                return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"10\" height=\"10\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"20 6 9 17 4 12\"></polyline></svg> Ready";
            case "Already Exists":
                return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"10\" height=\"10\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z\"></path><line x1=\"12\" y1=\"9\" x2=\"12\" y2=\"13\"></line><line x1=\"12\" y1=\"17\" x2=\"12.01\" y2=\"17\"></line></svg> Exists";
            case "Invalid Course":
                return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"10\" height=\"10\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"15\" y1=\"9\" x2=\"9\" y2=\"15\"></line><line x1=\"9\" y1=\"9\" x2=\"15\" y2=\"15\"></line></svg> Invalid";
            default:
                return status;
        }
    }
    
    #endregion
}
