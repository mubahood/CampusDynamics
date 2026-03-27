using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_PortalOnboarding : Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    public const int PageSize = 50;

    public int CurrentPage
    {
        get { return ViewState["cp"] != null ? (int)ViewState["cp"] : 0; }
        set { ViewState["cp"] = value; }
    }

    // ─── Page lifecycle ─────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        // Reload edit dropdown unconditionally (postback-safe)
        // ddlEditStatus is declarative with static items, so it survives ViewState.

        if (!IsPostBack)
        {
            LoadProgrammes();
            BindData();
        }
    }

    // ─── Main data bind ─────────────────────────────
    private void BindData()
    {
        string acadYear = GetCurrentAcadYear();

        // Base: portal users who have verified (simple!)
        string baseSql =
            "FROM campus_dynamics_portal.my_aspnet_users u " +
            "LEFT JOIN acad_student s ON s.regno = u.name " +
            "LEFT JOIN acad_programme p ON p.progcode = s.progid " +
            "LEFT JOIN acad_registration reg ON reg.regno = u.name AND reg.acad_year = @acadYear ";

        string where = "WHERE u.user_verification_status IS NOT NULL AND u.user_verification_status <> '' ";
        var parms = new System.Collections.Generic.List<MySqlParameter>();
        parms.Add(new MySqlParameter("@acadYear", acadYear));

        // Status filter
        string status = ddlStatus.SelectedValue;
        if (!string.IsNullOrEmpty(status))
        {
            where += "AND u.user_verification_status = @status ";
            parms.Add(new MySqlParameter("@status", status));
        }

        // Email filter
        string emailF = ddlEmail.SelectedValue;
        if (emailF == "YES")
            where += "AND u.verified_email IS NOT NULL AND u.verified_email <> '' ";
        else if (emailF == "NO")
            where += "AND (u.verified_email IS NULL OR u.verified_email = '') ";

        // Semester reg filter
        string semF = ddlSemReg.SelectedValue;
        if (semF == "YES")
            where += "AND reg.id IS NOT NULL ";
        else if (semF == "NO")
            where += "AND reg.id IS NULL ";

        // Programme filter
        string prog = ddlProgramme.SelectedValue;
        if (!string.IsNullOrEmpty(prog))
        {
            where += "AND s.progid = @progid ";
            parms.Add(new MySqlParameter("@progid", prog));
        }

        // Search
        string search = (txtSearch.Text ?? "").Trim();
        if (!string.IsNullOrEmpty(search))
        {
            where += "AND (u.name LIKE @q OR CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) LIKE @q OR u.verified_email LIKE @q) ";
            parms.Add(new MySqlParameter("@q", "%" + search + "%"));
        }

        // ── Count ───────────────────────────────────
        int totalRows = 0;
        try
        {
            string countSql = "SELECT COUNT(DISTINCT u.name) " + baseSql + where;
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(countSql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.Add(Clone(p));
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) totalRows = Convert.ToInt32(r);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("PO count: " + ex.Message);
        }

        int totalPages = Math.Max(1, (int)Math.Ceiling(totalRows / (double)PageSize));
        if (CurrentPage >= totalPages) CurrentPage = totalPages - 1;
        if (CurrentPage < 0) CurrentPage = 0;

        // ── Fetch page ──────────────────────────────
        string dataSql =
            "SELECT u.name AS regno, " +
            "CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) AS student_name, " +
            "IFNULL(p.progname, IFNULL(s.progid,'—')) AS progname, " +
            "u.user_verification_status AS verification_status, " +
            "IFNULL(u.verified_email,'') AS verified_email_addr, " +
            "CASE WHEN reg.id IS NOT NULL THEN '1' ELSE '0' END AS has_sem_reg, " +
            "IFNULL(DATE_FORMAT(u.lastactivitydate,'%d %b %Y %H:%i'),'—') AS last_activity " +
            baseSql + where +
            "GROUP BY u.name " +
            "ORDER BY u.lastactivitydate DESC " +
            "LIMIT @offset, @ps";

        DataTable dt = new DataTable();
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(dataSql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.Add(Clone(p));
                    cmd.Parameters.AddWithValue("@offset", CurrentPage * PageSize);
                    cmd.Parameters.AddWithValue("@ps", PageSize);
                    using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("PO data: " + ex.Message);
        }

        rptStudents.DataSource = dt;
        rptStudents.DataBind();

        pnlNoData.Visible = (dt.Rows.Count == 0);
        litCount.Text = totalRows.ToString("N0") + " record" + (totalRows != 1 ? "s" : "");
        litTotal.Text = totalRows.ToString("N0");
        litPage.Text = (CurrentPage + 1).ToString();
        litTotalPages.Text = totalPages.ToString();
        pnlPager.Visible = totalPages > 1;

        lnkFirst.Enabled = lnkPrev.Enabled = (CurrentPage > 0);
        lnkNext.Enabled = lnkLast.Enabled = (CurrentPage < totalPages - 1);

        // Summary
        LoadSummaryStats(acadYear);
    }

    // ─── Summary stats ──────────────────────────────
    private void LoadSummaryStats(string acadYear)
    {
        try
        {
            string sql =
                "SELECT " +
                "SUM(CASE WHEN u.user_verification_status = 'ACTIVE STUDENT' THEN 1 ELSE 0 END) AS a_cnt, " +
                "SUM(CASE WHEN u.user_verification_status = 'ALUMNI' THEN 1 ELSE 0 END) AS al_cnt, " +
                "SUM(CASE WHEN u.verified_email IS NOT NULL AND u.verified_email <> '' THEN 1 ELSE 0 END) AS e_cnt " +
                "FROM campus_dynamics_portal.my_aspnet_users u " +
                "WHERE u.user_verification_status IS NOT NULL AND u.user_verification_status <> ''";

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litActiveCount.Text = SafeInt(rdr, "a_cnt").ToString();
                        litAlumniCount.Text = SafeInt(rdr, "al_cnt").ToString();
                        litEmailCount.Text = SafeInt(rdr, "e_cnt").ToString();
                    }
                }
            }

            // Semester reg count
            string semSql =
                "SELECT COUNT(DISTINCT u.name) " +
                "FROM campus_dynamics_portal.my_aspnet_users u " +
                "INNER JOIN acad_registration reg ON reg.regno = u.name AND reg.acad_year = @ay " +
                "WHERE u.user_verification_status IS NOT NULL AND u.user_verification_status <> ''";
            using (var conn2 = new MySqlConnection(ConnStr))
            {
                conn2.Open();
                using (var cmd2 = new MySqlCommand(semSql, conn2))
                {
                    cmd2.Parameters.AddWithValue("@ay", acadYear);
                    object r = cmd2.ExecuteScalar();
                    litSemRegCount.Text = (r != null && r != DBNull.Value) ? Convert.ToInt32(r).ToString() : "0";
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("PO stats: " + ex.Message);
        }
    }

    // ─── Badge helpers ──────────────────────────────
    public string GetStatusBadge(string status)
    {
        if (string.IsNullOrEmpty(status))
            return "<span class='po-badge'>—</span>";
        string s = status.Trim().ToUpper();
        if (s.Contains("ACTIVE"))
            return "<span class='po-badge po-badge--active'>&#10003; Active Student</span>";
        if (s.Contains("ALUMNI"))
            return "<span class='po-badge po-badge--alumni'>&#9733; Alumni</span>";
        return "<span class='po-badge'>" + Server.HtmlEncode(status) + "</span>";
    }

    public string GetYesNo(bool val)
    {
        return val
            ? "<span class='po-yes'>&#10003; Yes</span>"
            : "<span class='po-no'>&#10007; No</span>";
    }

    public string GetEditLink(string regno)
    {
        if (string.IsNullOrEmpty(regno)) return "";
        string safe = Server.HtmlEncode(regno).Replace("'", "\\'");
        return "<a class='po-edit-link' href='javascript:void(0)' onclick=\"openEditModal('" + safe + "');\">Edit</a>";
    }

    // ─── Load Programmes ────────────────────────────
    private void LoadProgrammes()
    {
        try
        {
            string sql = "SELECT DISTINCT progcode, progname FROM acad_programme ORDER BY progname";
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                        ddlProgramme.Items.Add(new ListItem(rdr["progname"].ToString(), rdr["progcode"].ToString()));
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("PO progs: " + ex.Message);
        }
    }

    // ─── Academic year ──────────────────────────────
    private string GetCurrentAcadYear()
    {
        try { return AcademicYearHelper.GetCurrentAcademicYear(); }
        catch
        {
            try
            {
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("SELECT acadyear FROM acad_acadyears WHERE is_current_year='Yes' LIMIT 1", conn))
                    {
                        object v = cmd.ExecuteScalar();
                        return v != null ? v.ToString() : "";
                    }
                }
            }
            catch { return ""; }
        }
    }

    // ─── Utilities ──────────────────────────────────
    private static int SafeInt(IDataReader rdr, string col)
    {
        try
        {
            object v = rdr[col];
            return (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0;
        }
        catch { return 0; }
    }

    private static MySqlParameter Clone(MySqlParameter src)
    {
        return new MySqlParameter(src.ParameterName, src.Value);
    }

    // ─── Events ─────────────────────────────────────
    protected void btnSearch_Click(object sender, EventArgs e) { CurrentPage = 0; BindData(); }
    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlStatus.SelectedIndex = 0;
        ddlEmail.SelectedIndex = 0;
        ddlSemReg.SelectedIndex = 0;
        ddlProgramme.SelectedIndex = 0;
        CurrentPage = 0;
        BindData();
    }
    protected void ddlFilter_Changed(object sender, EventArgs e) { CurrentPage = 0; BindData(); }
    protected void lnkFirst_Click(object sender, EventArgs e) { CurrentPage = 0; BindData(); }
    protected void lnkPrev_Click(object sender, EventArgs e) { if (CurrentPage > 0) CurrentPage--; BindData(); }
    protected void lnkNext_Click(object sender, EventArgs e) { CurrentPage++; BindData(); }
    protected void lnkLast_Click(object sender, EventArgs e) { CurrentPage = 999999; BindData(); }

    // ─── Edit modal: save / load / reset ────────────
    protected void btnSaveEdit_Click(object sender, EventArgs e)
    {
        string mode = (hdnModalMode.Value ?? "").Trim().ToUpper();
        string regno = (hdnEditRegno.Value ?? "").Trim();

        if (string.IsNullOrEmpty(regno)) { BindData(); return; }

        if (mode == "LOAD")
        {
            LoadStudentForEdit(regno);
            return;
        }

        // Save mode
        string newStatus = Request.Form[ddlEditStatus.UniqueID] ?? "";
        string newEmail = (Request.Form[txtEditEmail.UniqueID] ?? "").Trim();

        try
        {
            string sql = "UPDATE campus_dynamics_portal.my_aspnet_users " +
                "SET user_verification_status = @status, verified_email = @email " +
                "WHERE name = @regno";
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@status", string.IsNullOrEmpty(newStatus) ? (object)DBNull.Value : newStatus);
                    cmd.Parameters.AddWithValue("@email", string.IsNullOrEmpty(newEmail) ? (object)DBNull.Value : newEmail);
                    cmd.Parameters.AddWithValue("@regno", regno);
                    cmd.ExecuteNonQuery();
                }
            }

            BindData();
            string js = "closeEditModal();showPoToast('Changes saved for " + JsEsc(regno) + ".','success');";
            ScriptManager.RegisterStartupScript(this, GetType(), "saved", js, true);
        }
        catch (Exception ex)
        {
            BindData();
            ShowModalError("Save failed: " + ex.Message);
        }
    }

    protected void btnResetVerification_Click(object sender, EventArgs e)
    {
        string regno = (hdnEditRegno.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno)) { BindData(); return; }

        try
        {
            string sql = "UPDATE campus_dynamics_portal.my_aspnet_users " +
                "SET user_verification_status = NULL, verified_email = NULL " +
                "WHERE name = @regno";
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    cmd.ExecuteNonQuery();
                }
            }

            BindData();
            string js = "closeEditModal();showPoToast('Verification reset for " + JsEsc(regno) + ". They must re-verify on the portal.','success');";
            ScriptManager.RegisterStartupScript(this, GetType(), "reset", js, true);
        }
        catch (Exception ex)
        {
            BindData();
            ShowModalError("Reset failed: " + ex.Message);
        }
    }

    private void LoadStudentForEdit(string regno)
    {
        BindData(); // Always rebind the grid

        string studentName = "";
        string progname = "";
        string status = "";
        string email = "";

        try
        {
            string sql =
                "SELECT CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) AS student_name, " +
                "IFNULL(p.progname, IFNULL(s.progid,'—')) AS progname, " +
                "IFNULL(u.user_verification_status,'') AS vstatus, " +
                "IFNULL(u.verified_email,'') AS vemail " +
                "FROM campus_dynamics_portal.my_aspnet_users u " +
                "LEFT JOIN acad_student s ON s.regno = u.name " +
                "LEFT JOIN acad_programme p ON p.progcode = s.progid " +
                "WHERE u.name = @r LIMIT 1";
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            studentName = rdr["student_name"].ToString().Trim();
                            progname = rdr["progname"].ToString();
                            status = rdr["vstatus"].ToString();
                            email = rdr["vemail"].ToString();
                        }
                    }
                }
            }
        }
        catch { }

        // Select the dropdown value
        TrySelect(ddlEditStatus, status);
        txtEditEmail.Text = email;

        // Open modal via JS, populate read-only labels
        string js = string.Format(
            "(function(){{" +
            "document.getElementById('lblEditRegno').textContent='{0}';" +
            "document.getElementById('lblEditName').textContent='{1}';" +
            "document.getElementById('lblEditProg').textContent='{2}';" +
            "showEditModal();" +
            "}})();",
            JsEsc(regno), JsEsc(studentName), JsEsc(progname));

        hdnModalMode.Value = "SAVE";
        ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", js, true);
    }

    private void TrySelect(DropDownList ddl, string value)
    {
        ddl.ClearSelection();
        var item = ddl.Items.FindByValue(value ?? "");
        if (item != null) item.Selected = true;
    }

    private void ShowModalError(string msg)
    {
        string js = "(function(){showEditModal();" +
            "var r=document.getElementById('modalResult');" +
            "r.className='po-toast po-toast--error';r.style.display='block';" +
            "r.textContent='" + JsEsc(msg) + "';})();";
        ScriptManager.RegisterStartupScript(this, GetType(), "err", js, true);
    }

    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
    }
}
