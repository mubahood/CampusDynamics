using System;
using System.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_PortalOnboarding : Page
{
    private static bool _userTypeColChecked = false;

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
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLowerInvariant();
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjaxAction(ajax);
            return;
        }

        // Reload edit dropdown unconditionally (postback-safe)
        // ddlEditStatus is declarative with static items, so it survives ViewState.

        if (!IsPostBack)
        {
            EnsurePortalOnboardingColumns();
            LoadProgrammes();
            BindData();
        }
    }

    private void HandleAjaxAction(string action)
    {
        Response.ContentType = "application/json";
        Response.Clear();

        try
        {
            switch (action)
            {
                case "resolve_email":
                    WriteResolvedEmailAjax();
                    break;
                case "save_onboarding":
                    WriteSaveOnboardingAjax();
                    break;
                default:
                    WriteJson(new Dictionary<string, object> { { "error", "Unknown action" } });
                    break;
            }
        }
        catch (Exception ex)
        {
            WriteJson(new Dictionary<string, object> { { "error", ex.Message } });
        }

        Response.End();
    }

    private void WriteJson(object data)
    {
        var serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;
        Response.Write(serializer.Serialize(data));
    }

    private void WriteResolvedEmailAjax()
    {
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        string userType = (Request.QueryString["userType"] ?? "STUDENT").Trim().ToUpperInvariant();

        if (string.IsNullOrEmpty(regno))
        {
            WriteJson(new Dictionary<string, object> { { "error", "Missing regno." } });
            return;
        }

        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            string source;
            string email = ResolveBestEmail(conn, regno, out source);

            WriteJson(new Dictionary<string, object>
            {
                { "success", true },
                { "email", email },
                { "source", source },
                { "userType", userType }
            });
        }
    }

    private string ResolveBestEmail(MySqlConnection conn, string regno, out string source)
    {
        source = string.Empty;
        if (conn == null || conn.State != ConnectionState.Open) return string.Empty;

        string id = (regno ?? "").Trim();
        if (string.IsNullOrEmpty(id)) return string.Empty;

        string email = string.Empty;

        using (var cmd = new MySqlCommand(
            "SELECT verified_email FROM campus_dynamics_portal.my_aspnet_users WHERE LOWER(TRIM(name))=LOWER(@r) LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@r", id);
            object r = cmd.ExecuteScalar();
            if (r != null && r != DBNull.Value) email = r.ToString().Trim();
            if (!string.IsNullOrEmpty(email)) source = "portal.my_aspnet_users.verified_email";
        }

        if (string.IsNullOrEmpty(email))
        {
            using (var cmd = new MySqlCommand(
                "SELECT emp_email FROM campus_dynamics.hrm_employee " +
                "WHERE usernames=@r OR EMP_CODE=@r OR LOWER(IFNULL(emp_email,''))=LOWER(@r) LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", id);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) email = r.ToString().Trim();
                if (!string.IsNullOrEmpty(email)) source = "campus_dynamics.hrm_employee.emp_email";
            }
        }

        if (string.IsNullOrEmpty(email))
        {
            using (var cmd = new MySqlCommand(
                "SELECT email FROM campus_dynamics.acad_student " +
                "WHERE regno=@r OR LOWER(IFNULL(email,''))=LOWER(@r) LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", id);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) email = r.ToString().Trim();
                if (!string.IsNullOrEmpty(email)) source = "campus_dynamics.acad_student.email";
            }
        }

        if (string.IsNullOrEmpty(email) && id.Contains("@"))
        {
            email = id;
            source = "input";
        }

        return email;
    }

    private void WriteSaveOnboardingAjax()
    {
        string mode = (Request.Form["mode"] ?? "SAVE").Trim().ToUpperInvariant();
        string regno = (Request.Form["regno"] ?? "").Trim();
        string status = (Request.Form["status"] ?? "").Trim();
        string email = (Request.Form["email"] ?? "").Trim();
        string userType = (Request.Form["userType"] ?? "STUDENT").Trim().ToUpperInvariant();

        if (string.IsNullOrEmpty(regno))
        {
            WriteJson(new Dictionary<string, object> { { "error", "Registration Number / Username is required." } });
            return;
        }

        if (string.IsNullOrEmpty(userType)) userType = "STUDENT";

        bool created;
        string finalEmail;
        SaveOnboardingRecord(mode, regno, status, email, userType, out created, out finalEmail);

        string message = created
            ? "Record created and verification saved for " + regno + "."
            : "Changes saved for " + regno + ".";

        WriteJson(new Dictionary<string, object>
        {
            { "success", true },
            { "created", created },
            { "regno", regno },
            { "email", finalEmail },
            { "message", message }
        });
    }

    private void SaveOnboardingRecord(string mode, string regno, string newStatus, string newEmail, string newUserType, out bool created, out string finalEmail)
    {
        created = false;
        finalEmail = newEmail;

        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();

            if (string.IsNullOrEmpty(finalEmail) || !finalEmail.Contains("@"))
            {
                string emailSource;
                string resolvedEmail = ResolveBestEmail(conn, regno, out emailSource);
                if (!string.IsNullOrEmpty(resolvedEmail))
                    finalEmail = resolvedEmail;
            }

            if (string.IsNullOrEmpty(finalEmail) || !finalEmail.Contains("@"))
                throw new Exception("A valid email is required. Email auto-fetch failed; please enter a valid email.");

            using (var tx = conn.BeginTransaction())
            {
                int affected;
                using (var upd = new MySqlCommand(
                    "UPDATE campus_dynamics_portal.my_aspnet_users " +
                    "SET user_verification_status = @status, verified_email = @email, user_type = @userType " +
                    "WHERE name = @regno", conn, tx))
                {
                    upd.Parameters.AddWithValue("@status", string.IsNullOrEmpty(newStatus) ? (object)DBNull.Value : newStatus);
                    upd.Parameters.AddWithValue("@email", string.IsNullOrEmpty(finalEmail) ? (object)DBNull.Value : finalEmail);
                    upd.Parameters.AddWithValue("@userType", newUserType);
                    upd.Parameters.AddWithValue("@regno", regno);
                    affected = upd.ExecuteNonQuery();
                }

                if (affected == 0)
                {
                    CreatePortalUserVerificationRecord(conn, tx, regno, newStatus, finalEmail, newUserType);
                    created = true;
                }

                tx.Commit();
            }
        }
    }

    private void EnsurePortalOnboardingColumns()
    {
        if (_userTypeColChecked) return;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA='campus_dynamics_portal' AND TABLE_NAME='my_aspnet_users' " +
                    "AND COLUMN_NAME='user_type'", conn))
                {
                    if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                    {
                        using (var alt = new MySqlCommand(
                            "ALTER TABLE campus_dynamics_portal.my_aspnet_users ADD COLUMN user_type VARCHAR(20) NULL DEFAULT 'STUDENT'", conn))
                            alt.ExecuteNonQuery();
                    }
                }
            }
            _userTypeColChecked = true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("PO migration user_type: " + ex.Message);
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
            "LEFT JOIN hrm_employee e ON (e.usernames = u.name OR e.EMP_CODE = u.name) " +
            "LEFT JOIN acad_programme p ON p.progcode = s.progid " +
            "LEFT JOIN acad_registration reg ON reg.regno = u.name AND reg.acad_year = @acadYear ";

        string where = "WHERE (" +
            "(u.user_verification_status IS NOT NULL AND u.user_verification_status <> '') " +
            "OR (UPPER(IFNULL(u.user_type,'STUDENT'))='LECTURER' AND u.verified_email IS NOT NULL AND u.verified_email <> '')" +
            ") ";
        var parms = new System.Collections.Generic.List<MySqlParameter>();
        parms.Add(new MySqlParameter("@acadYear", acadYear));

        // Status filter
        string status = ddlStatus.SelectedValue;
        if (!string.IsNullOrEmpty(status))
        {
            if (string.Equals(status, "LECTURER", StringComparison.OrdinalIgnoreCase))
            {
                where += "AND UPPER(IFNULL(u.user_type,'STUDENT'))='LECTURER' AND u.verified_email IS NOT NULL AND u.verified_email <> '' ";
            }
            else
            {
                where += "AND u.user_verification_status = @status ";
                parms.Add(new MySqlParameter("@status", status));
            }
        }

        // User type filter
        string userTypeF = ddlUserType.SelectedValue;
        if (!string.IsNullOrEmpty(userTypeF))
        {
            where += "AND UPPER(IFNULL(u.user_type,'STUDENT')) = @ut ";
            parms.Add(new MySqlParameter("@ut", userTypeF));
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
            "TRIM(CASE " +
            "WHEN UPPER(IFNULL(u.user_type,'STUDENT'))='LECTURER' THEN IFNULL(e.emp_name,'') " +
            "ELSE CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) END) AS student_name, " +
            "UPPER(IFNULL(u.user_type,'STUDENT')) AS user_type, " +
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
                "SUM(CASE WHEN u.verified_email IS NOT NULL AND u.verified_email <> '' THEN 1 ELSE 0 END) AS e_cnt, " +
                "SUM(CASE WHEN UPPER(IFNULL(u.user_type,'STUDENT'))='LECTURER' AND u.verified_email IS NOT NULL AND u.verified_email <> '' THEN 1 ELSE 0 END) AS lve_cnt " +
                "FROM campus_dynamics_portal.my_aspnet_users u " +
                "WHERE ((u.user_verification_status IS NOT NULL AND u.user_verification_status <> '') " +
                "OR UPPER(IFNULL(u.user_type,'STUDENT'))='LECTURER')";

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litActiveCount.Text = SafeInt(rdr, "a_cnt").ToString("N0");
                        litAlumniCount.Text = SafeInt(rdr, "al_cnt").ToString("N0");
                        litEmailCount.Text = SafeInt(rdr, "e_cnt").ToString("N0");
                        litLecturerEmailCount.Text = SafeInt(rdr, "lve_cnt").ToString("N0");
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
                    litSemRegCount.Text = (r != null && r != DBNull.Value) ? Convert.ToInt32(r).ToString("N0") : "0";
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

    public string GetUserTypeBadge(string userType)
    {
        string t = (userType ?? "").Trim().ToUpper();
        if (t == "LECTURER")
            return "<span class='po-badge po-badge--alumni'>&#128104;&#8205;&#127979; Lecturer</span>";
        return "<span class='po-badge po-badge--active'>&#127891; Student</span>";
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
        ddlUserType.SelectedIndex = 0;
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

    protected void btnRunBackfill_Click(object sender, EventArgs e)
    {
        EnsurePortalOnboardingColumns();

        int userTypeUpdated = 0;
        int usernamesNormalized = 0;
        int collisionsSkipped = 0;
        int hrEmailsSynced = 0;

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                using (var tx = conn.BeginTransaction())
                {
                    // 1) Backfill user_type for all accounts based on HR match.
                    using (var cmdType = new MySqlCommand(
                        "UPDATE campus_dynamics_portal.my_aspnet_users u " +
                        "LEFT JOIN hrm_employee e ON (" +
                        "e.usernames = u.name OR e.EMP_CODE = u.name OR " +
                        "LOWER(IFNULL(e.emp_email,'')) = LOWER(IFNULL(u.name,'')) OR " +
                        "LOWER(IFNULL(e.emp_email,'')) = LOWER(IFNULL(u.verified_email,''))" +
                        ") " +
                        "SET u.user_type = CASE WHEN e.empID IS NOT NULL THEN 'LECTURER' ELSE 'STUDENT' END", conn, tx))
                    {
                        userTypeUpdated = cmdType.ExecuteNonQuery();
                    }

                    // 2) Normalize usernames to verified university email when safe.
                    using (var sel = new MySqlCommand(
                        "SELECT u.id, u.name AS old_name, LOWER(TRIM(u.verified_email)) AS new_name " +
                        "FROM campus_dynamics_portal.my_aspnet_users u " +
                        "WHERE u.verified_email IS NOT NULL " +
                        "  AND TRIM(u.verified_email) <> '' " +
                        "  AND LOWER(TRIM(u.name)) <> LOWER(TRIM(u.verified_email))", conn, tx))
                    using (var rdr = sel.ExecuteReader())
                    {
                        var candidates = new System.Collections.Generic.List<Tuple<int, string>>();
                        while (rdr.Read())
                        {
                            int uid = rdr["id"] != DBNull.Value ? Convert.ToInt32(rdr["id"]) : 0;
                            string newName = rdr["new_name"] != DBNull.Value ? rdr["new_name"].ToString().Trim() : "";
                            if (uid > 0 && !string.IsNullOrEmpty(newName))
                                candidates.Add(new Tuple<int, string>(uid, newName));
                        }

                        rdr.Close();

                        foreach (var c in candidates)
                        {
                            int uid = c.Item1;
                            string newName = c.Item2;

                            bool collision = false;
                            using (var chk = new MySqlCommand(
                                "SELECT COUNT(*) FROM campus_dynamics_portal.my_aspnet_users WHERE LOWER(name)=@n AND id<>@id", conn, tx))
                            {
                                chk.Parameters.AddWithValue("@n", newName);
                                chk.Parameters.AddWithValue("@id", uid);
                                collision = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                            }

                            if (collision)
                            {
                                collisionsSkipped++;
                                continue;
                            }

                            using (var updUser = new MySqlCommand(
                                "UPDATE campus_dynamics_portal.my_aspnet_users " +
                                "SET name=@n, loweredname=LOWER(@n) " +
                                "WHERE id=@id", conn, tx))
                            {
                                updUser.Parameters.AddWithValue("@n", newName);
                                updUser.Parameters.AddWithValue("@id", uid);
                                updUser.ExecuteNonQuery();
                            }

                            using (var updMem = new MySqlCommand(
                                "UPDATE campus_dynamics_portal.my_aspnet_membership " +
                                "SET Email=@n, LoweredEmail=LOWER(@n) " +
                                "WHERE userId=@id", conn, tx))
                            {
                                updMem.Parameters.AddWithValue("@n", newName);
                                updMem.Parameters.AddWithValue("@id", uid);
                                updMem.ExecuteNonQuery();
                            }

                            usernamesNormalized++;
                        }
                    }

                    // 3) Sync verified lecturer emails into HR employee primary email field.
                    using (var syncHr = new MySqlCommand(
                        "UPDATE campus_dynamics.hrm_employee e " +
                        "INNER JOIN campus_dynamics_portal.my_aspnet_users u " +
                        "ON (e.usernames = u.name OR e.EMP_CODE = u.name OR LOWER(IFNULL(e.emp_email,'')) = LOWER(IFNULL(u.name,''))) " +
                        "SET e.emp_email = LOWER(TRIM(u.verified_email)) " +
                        "WHERE UPPER(IFNULL(u.user_type,'STUDENT'))='LECTURER' " +
                        "AND u.verified_email IS NOT NULL AND TRIM(u.verified_email)<>''", conn, tx))
                    {
                        hrEmailsSynced = syncHr.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }

            BindData();
            string msg = "Backfill complete. User type updated: " + userTypeUpdated +
                         ", usernames normalized: " + usernamesNormalized +
                         ", collisions skipped: " + collisionsSkipped +
                         ", HR emails synced: " + hrEmailsSynced + ".";
            ScriptManager.RegisterStartupScript(this, GetType(), "bf_ok", "showPoToast('" + JsEsc(msg) + "','success');", true);
        }
        catch (Exception ex)
        {
            BindData();
            ScriptManager.RegisterStartupScript(this, GetType(), "bf_err", "showPoToast('" + JsEsc("Backfill failed: " + ex.Message) + "','error');", true);
        }
    }

    // ─── Edit modal: save / load / reset ────────────
    protected void btnSaveEdit_Click(object sender, EventArgs e)
    {
        string mode = (hdnModalMode.Value ?? "").Trim().ToUpper();
        string regno = (hdnEditRegno.Value ?? "").Trim();

        if (mode == "CREATE")
            regno = (Request.Form["createRegnoInput"] ?? "").Trim();

        if (string.IsNullOrEmpty(regno)) { BindData(); return; }

        if (mode == "LOAD")
        {
            LoadStudentForEdit(regno);
            return;
        }

        // Save mode
        string newStatus = Request.Form[ddlEditStatus.UniqueID] ?? "";
        string newEmail = (Request.Form[txtEditEmail.UniqueID] ?? "").Trim();
        string newUserType = (Request.Form[ddlEditUserType.UniqueID] ?? "STUDENT").Trim().ToUpper();
        if (string.IsNullOrEmpty(newUserType)) newUserType = "STUDENT";
        bool created = false;
        string finalEmail = newEmail;

        try
        {
            SaveOnboardingRecord(mode, regno, newStatus, newEmail, newUserType, out created, out finalEmail);

            BindData();
            string msg = created
                ? "Record created and verification saved for " + regno + "."
                : "Changes saved for " + regno + ".";
            string js = "closeEditModal();showPoToast('" + JsEsc(msg) + "','success');";
            ScriptManager.RegisterStartupScript(this, GetType(), "saved", js, true);
            hdnModalMode.Value = "SAVE";
        }
        catch (Exception ex)
        {
            BindData();
            ShowModalError("Save failed: " + ex.Message);
        }
    }

    private void CreatePortalUserVerificationRecord(MySqlConnection conn, MySqlTransaction tx, string regno, string status, string email, string userType)
    {
        string cleanedRegno = (regno ?? "").Trim();
        if (string.IsNullOrEmpty(cleanedRegno))
            throw new Exception("Registration number is required.");

        string cleanedEmail = (email ?? "").Trim();
        string effectiveStatus = string.IsNullOrEmpty(status) ? "ACTIVE STUDENT" : status.Trim();
        string effectiveUserType = string.IsNullOrEmpty(userType) ? "STUDENT" : userType.Trim().ToUpper();
        DateTime now = DateTime.UtcNow;

        int applicationId = 1;
        using (var cmdApp = new MySqlCommand(
            "SELECT MIN(applicationId) FROM campus_dynamics_portal.my_aspnet_users WHERE applicationId IS NOT NULL", conn, tx))
        {
            object app = cmdApp.ExecuteScalar();
            if (app != null && app != DBNull.Value)
            {
                int parsed;
                if (int.TryParse(app.ToString(), out parsed) && parsed > 0)
                    applicationId = parsed;
            }
        }

        DataTable cols = new DataTable();
        using (var cmdCols = new MySqlCommand(
            "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, EXTRA " +
            "FROM INFORMATION_SCHEMA.COLUMNS " +
            "WHERE TABLE_SCHEMA='campus_dynamics_portal' AND TABLE_NAME='my_aspnet_users' " +
            "ORDER BY ORDINAL_POSITION", conn, tx))
        using (var da = new MySqlDataAdapter(cmdCols))
        {
            da.Fill(cols);
        }

        if (cols.Rows.Count == 0)
            throw new Exception("Could not read my_aspnet_users schema.");

        var insertCols = new System.Collections.Generic.List<string>();
        var insertVals = new System.Collections.Generic.List<string>();
        var insertParams = new System.Collections.Generic.List<MySqlParameter>();
        int idx = 0;

        foreach (DataRow row in cols.Rows)
        {
            string col = row["COLUMN_NAME"].ToString();
            string lower = col.ToLowerInvariant();
            string dataType = row["DATA_TYPE"].ToString().ToLowerInvariant();
            bool isNullable = string.Equals(row["IS_NULLABLE"].ToString(), "YES", StringComparison.OrdinalIgnoreCase);
            bool hasDefault = row["COLUMN_DEFAULT"] != DBNull.Value;
            string extra = row["EXTRA"].ToString().ToLowerInvariant();

            if (extra.Contains("auto_increment"))
                continue;

            object value = null;
            bool include = false;

            if (lower == "name")
            {
                value = cleanedRegno;
                include = true;
            }
            else if (lower == "loweredname")
            {
                value = cleanedRegno.ToLowerInvariant();
                include = true;
            }
            else if (lower == "applicationid")
            {
                value = applicationId;
                include = true;
            }
            else if (lower == "verified_email")
            {
                value = string.IsNullOrEmpty(cleanedEmail) ? (object)DBNull.Value : cleanedEmail;
                include = true;
            }
            else if (lower == "user_verification_status")
            {
                value = effectiveStatus;
                include = true;
            }
            else if (lower == "user_type")
            {
                value = effectiveUserType;
                include = true;
            }
            else if (lower == "isanonymous")
            {
                value = 0;
                include = true;
            }
            else if (lower.Contains("lastactivitydate"))
            {
                value = now;
                include = true;
            }
            else if (!isNullable && !hasDefault)
            {
                if (dataType.Contains("int") || dataType == "decimal" || dataType == "numeric" || dataType == "double" || dataType == "float" || dataType == "bit" || dataType == "boolean")
                    value = 0;
                else if (dataType.Contains("date") || dataType.Contains("time"))
                    value = now;
                else if (dataType.Contains("binary") || dataType.Contains("blob"))
                    value = new byte[0];
                else
                    value = string.Empty;

                include = true;
            }

            if (!include) continue;

            string p = "@p" + idx++;
            insertCols.Add(col);
            insertVals.Add(p);
            insertParams.Add(new MySqlParameter(p, value ?? DBNull.Value));
        }

        if (insertCols.Count == 0)
            throw new Exception("No insertable columns found for my_aspnet_users.");

        string sql =
            "INSERT INTO campus_dynamics_portal.my_aspnet_users (" + string.Join(", ", insertCols.ToArray()) + ") " +
            "VALUES (" + string.Join(", ", insertVals.ToArray()) + ")";

        using (var ins = new MySqlCommand(sql, conn, tx))
        {
            foreach (var p in insertParams) ins.Parameters.Add(p);
            ins.ExecuteNonQuery();
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

    protected void btnDeleteRecord_Click(object sender, EventArgs e)
    {
        string regno = (hdnEditRegno.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno)) { BindData(); return; }

        try
        {
            int deleted = 0;
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    int userId = 0;
                    using (var cmdUser = new MySqlCommand(
                        "SELECT id FROM campus_dynamics_portal.my_aspnet_users WHERE name=@regno LIMIT 1", conn, tx))
                    {
                        cmdUser.Parameters.AddWithValue("@regno", regno);
                        object uv = cmdUser.ExecuteScalar();
                        if (uv != null && uv != DBNull.Value)
                            int.TryParse(uv.ToString(), out userId);
                    }

                    if (userId <= 0)
                        throw new Exception("Record not found.");

                    if (TableExists(conn, tx, "campus_dynamics_portal", "my_aspnet_usersinroles") &&
                        ColumnExists(conn, tx, "campus_dynamics_portal", "my_aspnet_usersinroles", "userId"))
                    {
                        using (var cmd = new MySqlCommand(
                            "DELETE FROM campus_dynamics_portal.my_aspnet_usersinroles WHERE userId=@uid", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    if (TableExists(conn, tx, "campus_dynamics_portal", "my_aspnet_membership") &&
                        ColumnExists(conn, tx, "campus_dynamics_portal", "my_aspnet_membership", "userId"))
                    {
                        using (var cmd = new MySqlCommand(
                            "DELETE FROM campus_dynamics_portal.my_aspnet_membership WHERE userId=@uid", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    if (TableExists(conn, tx, "campus_dynamics_portal", "portal_email_otp"))
                    {
                        using (var cmd = new MySqlCommand(
                            "DELETE FROM campus_dynamics_portal.portal_email_otp WHERE LOWER(regno)=LOWER(@regno) OR LOWER(email)=LOWER(@regno)", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@regno", regno);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    using (var cmdDelete = new MySqlCommand(
                        "DELETE FROM campus_dynamics_portal.my_aspnet_users WHERE id=@uid", conn, tx))
                    {
                        cmdDelete.Parameters.AddWithValue("@uid", userId);
                        deleted = cmdDelete.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }

            BindData();
            if (deleted > 0)
            {
                string js = "closeEditModal();showPoToast('Record deleted for " + JsEsc(regno) + ".','success');";
                ScriptManager.RegisterStartupScript(this, GetType(), "del_ok", js, true);
            }
            else
            {
                ShowModalError("Delete failed: Record not found.");
            }
        }
        catch (Exception ex)
        {
            BindData();
            ShowModalError("Delete failed: " + ex.Message);
        }
    }

    private void LoadStudentForEdit(string regno)
    {
        BindData(); // Always rebind the grid

        string studentName = "";
        string progname = "";
        string status = "";
        string email = "";
        string userType = "STUDENT";

        try
        {
            string sql =
                "SELECT CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) AS student_name, " +
                "IFNULL(p.progname, IFNULL(s.progid,'—')) AS progname, " +
                "IFNULL(u.user_verification_status,'') AS vstatus, " +
                "IFNULL(u.verified_email,'') AS vemail, " +
                "UPPER(IFNULL(u.user_type,'STUDENT')) AS utype " +
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
                            userType = rdr["utype"].ToString();
                        }
                    }
                }
            }
        }
        catch { }

        // Select the dropdown value
        TrySelect(ddlEditUserType, userType);
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
        bool isCreate = string.Equals((hdnModalMode.Value ?? "").Trim(), "CREATE", StringComparison.OrdinalIgnoreCase);
        string js = "(function(){" +
            (isCreate ? "if(window.configureModalForCreate){configureModalForCreate();}" : "if(window.configureModalForEdit){configureModalForEdit();}") +
            "showEditModal();" +
            "var r=document.getElementById('modalResult');" +
            "r.className='po-toast po-toast--error';r.style.display='block';" +
            "r.textContent='" + JsEsc(msg) + "';})();";
        ScriptManager.RegisterStartupScript(this, GetType(), "err", js, true);
    }

    private static bool TableExists(MySqlConnection conn, MySqlTransaction tx, string schema, string table)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t", conn, tx))
            {
                cmd.Parameters.AddWithValue("@s", schema);
                cmd.Parameters.AddWithValue("@t", table);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    private static bool ColumnExists(MySqlConnection conn, MySqlTransaction tx, string schema, string table, string column)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn, tx))
            {
                cmd.Parameters.AddWithValue("@s", schema);
                cmd.Parameters.AddWithValue("@t", table);
                cmd.Parameters.AddWithValue("@c", column);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
    }
}
