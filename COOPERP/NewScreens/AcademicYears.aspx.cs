using System;
using System.Data;
using System.Web.UI;
using System.Globalization;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_AcademicYears : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle custom edit postback
        string target = Request["__EVENTTARGET"];
        string arg = Request["__EVENTARGUMENT"];
        if (target == "EditYear" && !string.IsNullOrEmpty(arg))
        {
            int editId;
            if (int.TryParse(arg, out editId))
            {
                LoadYearForEdit(editId);
                // Open the modal via script
                ScriptManager.RegisterStartupScript(this, GetType(), "openEdit",
                    "document.getElementById('modalOverlay').classList.add('open');", true);
            }
        }

        if (!IsPostBack)
        {
            BindGrid();
            LoadStats();
        }
    }

    // ───────────────────────────────────────────────────
    //  BIND GRID
    // ───────────────────────────────────────────────────

    private void BindGrid()
    {
        string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        string statusFilter = ddlStatusFilter.SelectedValue;

        string sql = "SELECT * FROM acad_acadyears";
        if (!string.IsNullOrEmpty(statusFilter))
            sql += " WHERE status = @st";
        sql += " ORDER BY acadyear DESC";

        DataTable dt = new DataTable();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
        }
        catch { }

        gridYears.DataSource = dt;
        gridYears.DataBind();

        litShowing.Text = dt.Rows.Count.ToString();
    }

    // ───────────────────────────────────────────────────
    //  LOAD STATS
    // ───────────────────────────────────────────────────

    private void LoadStats()
    {
        string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT
                        COUNT(*) AS total,
                        SUM(CASE WHEN status='Active' THEN 1 ELSE 0 END) AS active_count,
                        MAX(CASE WHEN is_current_year='Yes' THEN acadyear ELSE NULL END) AS current_acad,
                        MAX(CASE WHEN is_current_financial_year='Yes' THEN acadyear ELSE NULL END) AS current_fin
                    FROM acad_acadyears", conn))
                {
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            litTotal.Text = rdr["total"] != DBNull.Value ? rdr["total"].ToString() : "0";
                            litActive.Text = rdr["active_count"] != DBNull.Value ? rdr["active_count"].ToString() : "0";
                            litCurrentAcad.Text = rdr["current_acad"] != DBNull.Value ? rdr["current_acad"].ToString() : "—";
                            litCurrentFin.Text = rdr["current_fin"] != DBNull.Value ? rdr["current_fin"].ToString() : "—";
                        }
                    }
                }
            }
        }
        catch { }
    }

    // ───────────────────────────────────────────────────
    //  FILTER
    // ───────────────────────────────────────────────────

    protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
        LoadStats();
    }

    // ───────────────────────────────────────────────────
    //  GRID CALLBACK (unused placeholder)
    // ───────────────────────────────────────────────────

    protected void gridYears_CustomButtonCallback(object sender, DevExpress.Web.ASPxGridViewCustomButtonCallbackEventArgs e)
    {
    }

    // ───────────────────────────────────────────────────
    //  SAVE  (Add / Edit)
    // ───────────────────────────────────────────────────

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string startYearStr = txtStartYear.Text.Trim();
        int startYear;
        if (!int.TryParse(startYearStr, out startYear))
        {
            ShowAlert("Please enter a valid 4-digit start year.", true);
            return;
        }

        string acadyear = string.Format("{0}/{1}", startYear, startYear + 1);

        DateTime startDate;
        DateTime endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
        {
            ShowAlert("Please enter a valid start date.", true);
            return;
        }
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            ShowAlert("Please enter a valid end date.", true);
            return;
        }

        int semCount;
        if (!int.TryParse(ddlSemesterCount.SelectedValue, out semCount))
            semCount = 2;

        string desc = txtDescription.Text.Trim();
        string status = ddlStatus.SelectedValue;
        string user = Page.User.Identity.IsAuthenticated ? Page.User.Identity.Name : "system";

        string editIdStr = hfEditId.Value;
        int editId;
        bool isEdit = int.TryParse(editIdStr, out editId) && editId > 0;

        string result;
        if (isEdit)
        {
            result = AcademicYearHelper.UpdateAcademicYear(editId, acadyear, startDate, endDate, semCount, desc, status, user);
        }
        else
        {
            result = AcademicYearHelper.AddAcademicYear(acadyear, startDate, endDate, semCount, desc, status, user);
        }

        if (!string.IsNullOrEmpty(result))
        {
            ShowAlert(result, true);
            return;
        }

        // Set as current if checked
        if (chkSetCurrentAcad.Checked)
            AcademicYearHelper.SetCurrentAcademicYear(acadyear, user);
        if (chkSetCurrentFin.Checked)
            AcademicYearHelper.SetCurrentFinancialYear(acadyear, user);

        ShowAlert(isEdit ? "Academic year updated successfully." : "Academic year added successfully.", false);
        BindGrid();
        LoadStats();

        // Close modal via script
        ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", "closeModal();", true);
    }

    // ───────────────────────────────────────────────────
    //  SET CURRENT  (from Set Current modal)
    // ───────────────────────────────────────────────────

    protected void btnSetCurrent_Click(object sender, EventArgs e)
    {
        string acadyear = hfSetCurrentYear.Value;
        if (string.IsNullOrEmpty(acadyear))
        {
            ShowAlert("No academic year selected.", true);
            return;
        }

        string user = Page.User.Identity.IsAuthenticated ? Page.User.Identity.Name : "system";

        if (chkSetAcad.Checked)
        {
            string res = AcademicYearHelper.SetCurrentAcademicYear(acadyear, user);
            if (!string.IsNullOrEmpty(res)) { ShowAlert(res, true); return; }
        }
        if (chkSetFin.Checked)
        {
            string res = AcademicYearHelper.SetCurrentFinancialYear(acadyear, user);
            if (!string.IsNullOrEmpty(res)) { ShowAlert(res, true); return; }
        }

        if (!chkSetAcad.Checked && !chkSetFin.Checked)
        {
            ShowAlert("Please select at least one option (Academic Year or Financial Year).", true);
            return;
        }

        ShowAlert(string.Format("{0} has been set as current.", acadyear), false);
        BindGrid();
        LoadStats();

        ScriptManager.RegisterStartupScript(this, GetType(), "closeSetCurrent", "closeSetCurrentModal();", true);
    }

    // ───────────────────────────────────────────────────
    //  LOAD FOR EDIT
    // ───────────────────────────────────────────────────

    private void LoadYearForEdit(int id)
    {
        DataRow row = AcademicYearHelper.GetAcademicYearById(id);
        if (row == null) return;

        hfEditId.Value = id.ToString();

        string acadyear = row["acadyear"].ToString();
        string[] parts = acadyear.Split('/');
        if (parts.Length == 2)
        {
            txtStartYear.Text = parts[0];
            txtEndYear.Text = parts[1];
        }

        if (row["start_date"] != DBNull.Value)
            txtStartDate.Text = ((DateTime)row["start_date"]).ToString("yyyy-MM-dd");
        if (row["end_date"] != DBNull.Value)
            txtEndDate.Text = ((DateTime)row["end_date"]).ToString("yyyy-MM-dd");

        if (row["semester_count"] != DBNull.Value)
        {
            string sc = row["semester_count"].ToString();
            if (ddlSemesterCount.Items.FindByValue(sc) != null)
                ddlSemesterCount.SelectedValue = sc;
        }

        if (row["status"] != DBNull.Value)
        {
            string st = row["status"].ToString();
            if (ddlStatus.Items.FindByValue(st) != null)
                ddlStatus.SelectedValue = st;
        }

        txtDescription.Text = row["description"] != DBNull.Value ? row["description"].ToString() : "";

        chkSetCurrentAcad.Checked = row["is_current_year"].ToString() == "Yes";
        chkSetCurrentFin.Checked = row["is_current_financial_year"].ToString() == "Yes";

        // Set modal title via script
        ScriptManager.RegisterStartupScript(this, GetType(), "setEditTitle",
            "document.getElementById('modalTitle').textContent='Edit Academic Year';" +
            "document.getElementById('yearPreview').textContent='" + acadyear + "';", true);
    }

    // ───────────────────────────────────────────────────
    //  ALERT HELPER
    // ───────────────────────────────────────────────────

    private void ShowAlert(string message, bool isError)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = isError ? "ay-alert ay-alert--error" : "ay-alert ay-alert--success";
        pnlAlert.Controls.Clear();
        pnlAlert.Controls.Add(new System.Web.UI.LiteralControl(message));
    }
}
