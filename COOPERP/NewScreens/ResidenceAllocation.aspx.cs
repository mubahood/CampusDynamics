using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;
using DevExpress.Web;
using DevExpress.Export;
using DevExpress.XtraPrinting;

public partial class COOPERP_NewScreens_ResidenceAllocation : System.Web.UI.Page
{
    private string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAcadYears();
            LoadProgrammes();
            LoadHalls();
            LoadHallsSummary();
            LoadStats();
            LoadResidenceData();
        }
    }

    #region Load Dropdowns

    private void LoadAcadYears()
    {
        ddlAcadYear.Items.Clear();
        int currentYear = DateTime.Now.Year;
        int startYear = currentYear - 5;
        int endYear = currentYear + 2;

        for (int y = endYear; y >= startYear; y--)
        {
            string yearStr = y.ToString() + "/" + (y + 1).ToString();
            ddlAcadYear.Items.Add(new ListItem(yearStr, yearStr));
        }

        // Default to current academic year
        string defaultYear = currentYear.ToString() + "/" + (currentYear + 1).ToString();
        if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
            ddlAcadYear.SelectedValue = defaultYear;

        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }

    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));

        string sql = "SELECT DISTINCT progcode, progname FROM acad_programme WHERE progcode IS NOT NULL ORDER BY progname";

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string code = dr["progcode"].ToString();
                        string name = dr["progname"].ToString();
                        ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }
    }

    private void LoadHalls()
    {
        string sql = "SELECT ID, hall_name, hall_capacity FROM acad_halls WHERE hall_name IS NOT NULL ORDER BY hall_name";

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlAllocHall.Items.Clear();
                    ddlAllocHall.Items.Add(new ListItem("-- Select Hall --", ""));
                    ddlPopupHall.Items.Clear();
                    ddlPopupHall.Items.Add(new ListItem("-- Select Hall --", ""));

                    while (dr.Read())
                    {
                        string id = dr["ID"].ToString();
                        string name = dr["hall_name"].ToString();
                        int capacity = Convert.ToInt32(dr["hall_capacity"] == DBNull.Value ? 0 : dr["hall_capacity"]);
                        string display = name + " (Cap: " + capacity.ToString() + ")";

                        ddlAllocHall.Items.Add(new ListItem(display, id));
                        ddlPopupHall.Items.Add(new ListItem(display, id));
                    }
                }
            }
        }
    }

    #endregion

    #region Load Data

    private void LoadHallsSummary()
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        string sql = @"
            SELECT 
                h.ID,
                h.hall_name,
                COALESCE(h.hall_capacity, 0) as hall_capacity,
                COALESCE((SELECT COUNT(*) FROM acad_residence r WHERE r.hall_id = h.ID AND r.acadyear = @acadyear AND r.semester = @semester), 0) as allocated,
                COALESCE(h.hall_capacity, 0) - COALESCE((SELECT COUNT(*) FROM acad_residence r WHERE r.hall_id = h.ID AND r.acadyear = @acadyear AND r.semester = @semester), 0) as available
            FROM acad_halls h
            WHERE h.hall_name IS NOT NULL
            ORDER BY h.hall_name";

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        rptHalls.DataSource = dt;
        rptHalls.DataBind();
    }

    private void LoadStats()
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        // Count allocated (students with hall_id)
        string sqlAllocated = @"SELECT COUNT(*) FROM acad_residence WHERE hall_id IS NOT NULL AND hall_id > 0 AND acadyear = @acadyear AND semester = @semester";

        // Count unallocated (students with residence_status=RESIDENT but no hall assigned)
        string sqlUnallocated = @"SELECT COUNT(*) FROM acad_registration reg
            LEFT JOIN acad_residence res ON reg.regno = res.regno AND res.acadyear = @acadyear AND res.semester = @semester
            WHERE reg.residence_status = 'RESIDENT' AND reg.acad_year = @acadyear
            AND (res.hall_id IS NULL OR res.hall_id = 0)";

        // Total hall capacity
        string sqlCapacity = "SELECT COALESCE(SUM(hall_capacity), 0) FROM acad_halls";

        // Registered students
        string sqlRegistered = "SELECT COUNT(*) FROM acad_registration WHERE acad_year = @acadyear AND regstatus = 'Registered'";

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            // Allocated
            using (MySqlCommand cmd = new MySqlCommand(sqlAllocated, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                litAllocated.Text = cmd.ExecuteScalar().ToString();
            }

            // Unallocated
            using (MySqlCommand cmd = new MySqlCommand(sqlUnallocated, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                litUnallocated.Text = cmd.ExecuteScalar().ToString();
            }

            // Capacity
            using (MySqlCommand cmd = new MySqlCommand(sqlCapacity, conn))
            {
                litCapacity.Text = cmd.ExecuteScalar().ToString();
            }

            // Registered
            using (MySqlCommand cmd = new MySqlCommand(sqlRegistered, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                litRegistered.Text = cmd.ExecuteScalar().ToString();
            }
        }
    }

    private void LoadResidenceData()
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        litAcadYearDisplay.Text = acadYear;
        litSemesterDisplay.Text = semester;

        string sql = @"
            SELECT 
                COALESCE(res.ID, 0) as ID,
                reg.regno,
                CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) as student_name,
                s.progid,
                reg.studyyear,
                reg.residence_status,
                h.hall_name,
                res.room_id,
                reg.regstatus
            FROM acad_registration reg
            INNER JOIN acad_student s ON reg.regno = s.regno
            LEFT JOIN acad_residence res ON reg.regno = res.regno AND res.acadyear = @acadyear AND res.semester = @semester
            LEFT JOIN acad_halls h ON res.hall_id = h.ID
            WHERE reg.acad_year = @acadyear";

        // Apply filters
        if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
        {
            sql += " AND reg.studyyear = @studyyear";
        }

        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            sql += " AND s.progid = @progid";
        }

        if (!string.IsNullOrEmpty(ddlResidenceStatus.SelectedValue))
        {
            sql += " AND reg.residence_status = @residence_status";
        }

        sql += " ORDER BY s.firstname, s.othername";

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);

                if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
                    cmd.Parameters.AddWithValue("@studyyear", ddlStudyYear.SelectedValue);

                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    cmd.Parameters.AddWithValue("@progid", ddlProgramme.SelectedValue);

                if (!string.IsNullOrEmpty(ddlResidenceStatus.SelectedValue))
                    cmd.Parameters.AddWithValue("@residence_status", ddlResidenceStatus.SelectedValue);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        gvResidence.DataSource = dt;
        gvResidence.DataBind();

        litSelectedCount.Text = "0";
    }

    #endregion

    #region Helper Methods

    protected string GetResidenceClass(string status)
    {
        if (string.IsNullOrEmpty(status)) return "nonresident";
        return status.ToUpper().Contains("RESIDENT") && !status.ToUpper().Contains("NON") ? "resident" : "nonresident";
    }

    protected string GetOccupancyPercent(object allocated, object capacity)
    {
        int alloc = Convert.ToInt32(allocated ?? 0);
        int cap = Convert.ToInt32(capacity ?? 0);
        if (cap == 0) return "0";
        double pct = (double)alloc / cap * 100;
        return pct > 100 ? "100" : pct.ToString("0");
    }

    private void ShowMessage(string message)
    {
        litMessage.Text = message;
        popMessage.ShowOnPageLoad = true;
    }

    private void RefreshData()
    {
        LoadHallsSummary();
        LoadStats();
        LoadResidenceData();
    }

    #endregion

    #region Filter Events

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        RefreshData();
    }

    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        RefreshData();
    }

    protected void ddlStudyYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadResidenceData();
    }

    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadResidenceData();
    }

    protected void ddlResidenceStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadResidenceData();
    }

    #endregion

    #region Allocation Actions

    protected void btnCreateList_Click(object sender, EventArgs e)
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        // Create residence entries for students with residence_status = 'RESIDENT' who don't have an entry yet
        string sql = @"
            INSERT INTO acad_residence (regno, acadyear, semester, study_year)
            SELECT reg.regno, @acadyear, @semester, reg.studyyear
            FROM acad_registration reg
            WHERE reg.acad_year = @acadyear
            AND reg.residence_status = 'RESIDENT'
            AND NOT EXISTS (
                SELECT 1 FROM acad_residence res 
                WHERE res.regno = reg.regno AND res.acadyear = @acadyear AND res.semester = @semester
            )";

        int count = 0;
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                count = cmd.ExecuteNonQuery();
            }
        }

        ShowMessage(count.ToString() + " residence entries created.");
        RefreshData();
    }

    protected void btnAllocate_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResidence.GetSelectedFieldValues("ID", "regno");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select students to allocate.");
            return;
        }

        if (string.IsNullOrEmpty(ddlAllocHall.SelectedValue))
        {
            ShowMessage("Please select a hall.");
            return;
        }

        int hallId = Convert.ToInt32(ddlAllocHall.SelectedValue);
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        int updated = 0;
        int created = 0;

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            foreach (object key in selectedKeys)
            {
                object[] vals = (object[])key;
                int id = Convert.ToInt32(vals[0]);
                string regno = vals[1].ToString();

                if (id > 0)
                {
                    // Update existing
                    string updateSql = "UPDATE acad_residence SET hall_id = @hall_id WHERE ID = @id";
                    using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@hall_id", hallId);
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                        updated++;
                    }
                }
                else
                {
                    // Create new residence entry
                    string insertSql = @"INSERT INTO acad_residence (regno, acadyear, semester, hall_id, study_year)
                        SELECT @regno, @acadyear, @semester, @hall_id, reg.studyyear
                        FROM acad_registration reg
                        WHERE reg.regno = @regno AND reg.acad_year = @acadyear
                        LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@regno", regno);
                        cmd.Parameters.AddWithValue("@acadyear", acadYear);
                        cmd.Parameters.AddWithValue("@semester", semester);
                        cmd.Parameters.AddWithValue("@hall_id", hallId);
                        cmd.ExecuteNonQuery();
                        created++;
                    }
                }
            }
        }

        ShowMessage(updated.ToString() + " updated, " + created.ToString() + " created.");
        RefreshData();
        gvResidence.Selection.UnselectAll();
    }

    protected void btnRemoveAllocation_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResidence.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select students to remove allocation.");
            return;
        }

        int count = 0;
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            foreach (object key in selectedKeys)
            {
                int id = Convert.ToInt32(key);
                if (id > 0)
                {
                    string sql = "UPDATE acad_residence SET hall_id = NULL, room_id = NULL WHERE ID = @id";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                        count++;
                    }
                }
            }
        }

        ShowMessage(count.ToString() + " allocation(s) removed.");
        RefreshData();
        gvResidence.Selection.UnselectAll();
    }

    protected void btnAllocateSingle_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        hfAssignId.Value = btn.CommandArgument;
        popAssignHall.ShowOnPageLoad = true;
    }

    protected void btnDoAssign_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlPopupHall.SelectedValue))
        {
            ShowMessage("Please select a hall.");
            return;
        }

        int id = Convert.ToInt32(hfAssignId.Value);
        int hallId = Convert.ToInt32(ddlPopupHall.SelectedValue);
        string roomId = txtRoomId.Text.Trim();

        string sql = "UPDATE acad_residence SET hall_id = @hall_id, room_id = @room_id WHERE ID = @id";
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@hall_id", hallId);
                cmd.Parameters.AddWithValue("@room_id", string.IsNullOrEmpty(roomId) ? DBNull.Value : (object)roomId);
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
        }

        popAssignHall.ShowOnPageLoad = false;
        ShowMessage("Hall assigned successfully.");
        RefreshData();
    }

    protected void btnRemoveSingle_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = Convert.ToInt32(btn.CommandArgument);

        string sql = "UPDATE acad_residence SET hall_id = NULL, room_id = NULL WHERE ID = @id";
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
        }

        ShowMessage("Allocation removed.");
        RefreshData();
    }

    protected void btnViewProfile_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        string regno = btn.CommandArgument;
        Response.Redirect("~/COOPERP/StudentProfile.aspx?regno=" + Server.UrlEncode(regno));
    }

    #endregion

    #region Export & Print

    protected void btnPrintList_Click(object sender, EventArgs e)
    {
        // Generate printable list
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        string sql = @"
            SELECT 
                s.regno,
                CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) as student_name,
                s.progid,
                res.study_year,
                h.hall_name,
                res.room_id
            FROM acad_residence res
            INNER JOIN acad_student s ON res.regno = s.regno
            LEFT JOIN acad_halls h ON res.hall_id = h.ID
            WHERE res.acadyear = @acadyear AND res.semester = @semester
            AND res.hall_id IS NOT NULL AND res.hall_id > 0
            ORDER BY h.hall_name, s.firstname, s.othername";

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@acadyear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        // Build print HTML
        string html = @"<html><head><title>Residence List - " + acadYear + " Sem " + semester + @"</title>
            <style>
                body { font-family: Arial, sans-serif; font-size: 12px; }
                table { width: 100%; border-collapse: collapse; }
                th, td { border: 1px solid #000; padding: 6px; text-align: left; }
                th { background: #f0f0f0; font-weight: bold; }
                h2 { text-align: center; }
                @media print { button { display: none; } }
            </style>
        </head><body>
        <button onclick='window.print()' style='margin-bottom:10px;'>Print</button>
        <h2>Residence Allocation List</h2>
        <p style='text-align:center;'>Academic Year: " + acadYear + " | Semester: " + semester + @"</p>
        <table>
            <tr><th>#</th><th>Reg No</th><th>Student Name</th><th>Programme</th><th>Year</th><th>Hall</th><th>Room</th></tr>";

        int row = 1;
        foreach (DataRow dr in dt.Rows)
        {
            html += "<tr><td>" + row++ + "</td>";
            html += "<td>" + dr["regno"] + "</td>";
            html += "<td>" + dr["student_name"] + "</td>";
            html += "<td>" + dr["progid"] + "</td>";
            html += "<td>" + dr["study_year"] + "</td>";
            html += "<td>" + dr["hall_name"] + "</td>";
            html += "<td>" + dr["room_id"] + "</td></tr>";
        }

        html += "</table></body></html>";

        Response.Clear();
        Response.ContentType = "text/html";
        Response.Write(html);
        Response.End();
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        gveResidence.WriteXlsxToResponse(new XlsxExportOptionsEx() { ExportType = ExportType.WYSIWYG });
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        RefreshData();
    }

    #endregion
}
