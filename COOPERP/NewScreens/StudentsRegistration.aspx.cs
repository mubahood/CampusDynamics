using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
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

    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    // ===================================================================
    // PAGE LIFECYCLE
    // ===================================================================

    protected void Page_Load(object sender, EventArgs e)
    {
        // Short-circuit for AJAX requests (preview / batch processing)
        if (HandleAjaxRequest()) return;

        // ALWAYS reload dropdown items — ViewState is disabled on master page,
        // so dropdown items are lost on every postback. ASP.NET's second
        // ProcessPostData pass will restore user selections from posted form
        // data once the items are available.
        LoadAcademicYears();
        LoadProgrammes();

        if (!IsPostBack)
        {
            // Filter defaults: current academic year + current semester
            // ddlAcadYear already has current year selected by PopulateDropDown
            int curSem = AcademicYearHelper.GetCurrentSemester();
            if (curSem >= 1 && curSem <= 3)
                ddlSemester.SelectedValue = curSem.ToString();

            ApplyFiltersFromQueryString();

            // Form defaults: current period
            ddlAddSemester.SelectedValue = curSem.ToString();
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
    }

    // ===================================================================
    // HELPERS - Academic Year / Semester (centralised in AcademicYearHelper)
    // ===================================================================

    private void LoadAcademicYears()
    {
        // Main filter dropdown (with "All" option, select current year)
        AcademicYearHelper.PopulateDropDown(ddlAcadYear, true, true);

        // Form dropdown (no "All" option, default to current year)
        AcademicYearHelper.PopulateDropDown(ddlAddAcadYear, false, true);
    }

    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("All Programmes", ""));
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand("SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlProgramme.Items.Add(new ListItem(
                            rdr["progcode"] + " - " + rdr["progname"], rdr["progcode"].ToString()));
            }
        }
        catch { /* non-fatal */ }
    }

    private void UpdateDisplayLabels()
    {
        string yr  = string.IsNullOrEmpty(ddlAcadYear.SelectedValue) ? "All Years"    : ddlAcadYear.SelectedValue;
        string sem = string.IsNullOrEmpty(ddlSemester.SelectedValue) ? "All Semesters" : "Sem " + ddlSemester.SelectedValue;
        litAcadYearDisplay.Text = yr;
        litSemesterDisplay.Text = sem;
        litAcadContext.Text = string.Format(
            "<span style='font-size:11px;color:#174DA4;background:rgba(23,77,164,.08);padding:4px 10px;border-radius:10px;font-weight:600;'>{0} &nbsp;·&nbsp; {1}</span>",
            Server.HtmlEncode(yr), Server.HtmlEncode(sem));
    }

    private void ApplyFiltersFromQueryString()
    {
        string q = (Request.QueryString["q"] ?? "").Trim();
        if (!string.IsNullOrEmpty(q)) txtSearch.Text = q;

        SetSelectedIfExists(ddlAcadYear, Request.QueryString["ay"] ?? "");
        SetSelectedIfExists(ddlSemester, Request.QueryString["sem"] ?? "");
        SetSelectedIfExists(ddlStudyYear, Request.QueryString["sy"] ?? "");
        SetSelectedIfExists(ddlRegStatus, Request.QueryString["rs"] ?? "");
        SetSelectedIfExists(ddlProgramme, Request.QueryString["prog"] ?? "");
        SetSelectedIfExists(ddlExamClearance, Request.QueryString["ec"] ?? "");
        SetSelectedIfExists(ddlIDCard, Request.QueryString["idc"] ?? "");
        SetSelectedIfExists(ddlResidence, Request.QueryString["res"] ?? "");
        SetSelectedIfExists(ddlBilling, Request.QueryString["bill"] ?? "");
        SetSelectedIfExists(ddlPageSize, Request.QueryString["per"] ?? "");
    }

    private void SetSelectedIfExists(ListControl control, string value)
    {
        if (control == null) return;
        if (string.IsNullOrEmpty(value)) return;
        var item = control.Items.FindByValue(value);
        if (item != null)
        {
            control.ClearSelection();
            item.Selected = true;
        }
    }

    private int ParseQueryInt(string key, int defaultValue, int minValue, int maxValue)
    {
        int value;
        if (!int.TryParse(Request.QueryString[key], out value)) value = defaultValue;
        if (value < minValue) value = minValue;
        if (value > maxValue) value = maxValue;
        return value;
    }

    private string BuildListUrl(int page)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);

        if (!string.IsNullOrEmpty(txtSearch.Text.Trim())) query["q"] = txtSearch.Text.Trim();
        if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue)) query["ay"] = ddlAcadYear.SelectedValue;
        if (!string.IsNullOrEmpty(ddlSemester.SelectedValue)) query["sem"] = ddlSemester.SelectedValue;
        if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue)) query["sy"] = ddlStudyYear.SelectedValue;
        if (!string.IsNullOrEmpty(ddlRegStatus.SelectedValue)) query["rs"] = ddlRegStatus.SelectedValue;
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue)) query["prog"] = ddlProgramme.SelectedValue;
        if (!string.IsNullOrEmpty(ddlExamClearance.SelectedValue)) query["ec"] = ddlExamClearance.SelectedValue;
        if (!string.IsNullOrEmpty(ddlIDCard.SelectedValue)) query["idc"] = ddlIDCard.SelectedValue;
        if (!string.IsNullOrEmpty(ddlResidence.SelectedValue)) query["res"] = ddlResidence.SelectedValue;
        if (!string.IsNullOrEmpty(ddlBilling.SelectedValue)) query["bill"] = ddlBilling.SelectedValue;
        if (!string.IsNullOrEmpty(ddlPageSize.SelectedValue)) query["per"] = ddlPageSize.SelectedValue;

        query["page"] = (page < 1 ? 1 : page).ToString();

        string q = query.ToString();
        return ResolveUrl("~/COOPERP/NewScreens/StudentsRegistration.aspx") + (string.IsNullOrEmpty(q) ? "" : "?" + q);
    }

    private string BuildPagerHtml(int page, int totalPages)
    {
        if (totalPages <= 1) return "";

        var html = new StringBuilder();

        if (page > 1) html.AppendFormat("<a href='{0}'>Prev</a>", BuildListUrl(page - 1));
        else html.Append("<span class='is-disabled'>Prev</span>");

        int start = Math.Max(1, page - 3);
        int end = Math.Min(totalPages, page + 3);

        if (start > 1)
        {
            html.AppendFormat("<a href='{0}'>1</a>", BuildListUrl(1));
            if (start > 2) html.Append("<span class='is-disabled'>…</span>");
        }

        for (int p = start; p <= end; p++)
        {
            if (p == page) html.AppendFormat("<span class='is-active'>{0}</span>", p);
            else html.AppendFormat("<a href='{0}'>{1}</a>", BuildListUrl(p), p);
        }

        if (end < totalPages)
        {
            if (end < totalPages - 1) html.Append("<span class='is-disabled'>…</span>");
            html.AppendFormat("<a href='{0}'>{1}</a>", BuildListUrl(totalPages), totalPages);
        }

        if (page < totalPages) html.AppendFormat("<a href='{0}'>Next</a>", BuildListUrl(page + 1));
        else html.Append("<span class='is-disabled'>Next</span>");

        return html.ToString();
    }

    private void RedirectToList(int page)
    {
        Response.Redirect(BuildListUrl(page), false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void RedirectCleanList()
    {
        Response.Redirect(ResolveUrl("~/COOPERP/NewScreens/StudentsRegistration.aspx"), false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private string GetCurrentUser()
    {
        if (Session["username"] != null && Session["username"].ToString().Trim() != "")
            return Session["username"].ToString().Trim();
        if (HttpContext.Current.User.Identity.IsAuthenticated)
            return HttpContext.Current.User.Identity.Name;
        return "system";
    }

    // ===================================================================
    // STATS
    // ===================================================================

    private void LoadStats()
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;

        var sb = new StringBuilder(@"
            SELECT
                COUNT(*)                                                          AS total,
                SUM(CASE WHEN r.regstatus = 'UNREGISTERED'    THEN 1 ELSE 0 END)  AS unregistered,
                SUM(CASE WHEN r.regstatus = 'REGISTERED'      THEN 1 ELSE 0 END)  AS registered,
                SUM(CASE WHEN r.regstatus = 'LATE REGISTERED' THEN 1 ELSE 0 END)  AS late_reg,
                SUM(CASE WHEN r.regstatus = 'CLEARED'         THEN 1 ELSE 0 END)  AS cleared,
                SUM(CASE WHEN r.regstatus = 'DISCONTINUED'    THEN 1 ELSE 0 END)  AS discontinued,
                SUM(CASE WHEN r.regstatus = 'HALTED'          THEN 1 ELSE 0 END)  AS halted,
                SUM(CASE WHEN r.regstatus = 'DEAD YEAR'       THEN 1 ELSE 0 END)  AS dead_year,
                SUM(CASE WHEN sreg.new_status = 'ACTIVE' AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                    AND EXISTS(
                        SELECT 1
                        FROM campus_dynamics_accounts.fin_studentfeestracking ft
                        WHERE ft.regno = COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno))
                          AND ft.acadyear = r.acad_year
                          AND ft.semester = r.semester
                          AND ft.trans_type = 'Bill'
                    )
                THEN 1 ELSE 0 END) AS billed,
                SUM(CASE WHEN sreg.new_status = 'ACTIVE' AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                    AND NOT EXISTS(
                        SELECT 1
                        FROM campus_dynamics_accounts.fin_studentfeestracking ft
                        WHERE ft.regno = COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno))
                          AND ft.acadyear = r.acad_year
                          AND ft.semester = r.semester
                          AND ft.trans_type = 'Bill'
                    )
                THEN 1 ELSE 0 END) AS not_billed
            FROM acad_registration r
            LEFT JOIN acad_student sreg ON TRIM(sreg.regno) = TRIM(r.regno)
            WHERE 1=1");

        var parms = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(acadYear)) { sb.Append(" AND r.acad_year = @ay");  parms.Add(new MySqlParameter("@ay", acadYear)); }
        if (!string.IsNullOrEmpty(semester)) { sb.Append(" AND r.semester  = @sem"); parms.Add(new MySqlParameter("@sem", SafeInt(semester, 1))); }

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sb.ToString(), conn))
                {
                    cmd.CommandTimeout = 30;
                    foreach (var p in parms) cmd.Parameters.Add(p);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            litTotal.Text          = FormatCount(rdr["total"]);
                            litUnregistered.Text   = FormatCount(rdr["unregistered"]);
                            litRegistered.Text     = FormatCount(rdr["registered"]);
                            litLateRegistered.Text = FormatCount(rdr["late_reg"]);
                            litCleared.Text        = FormatCount(rdr["cleared"]);
                            litDiscontinued.Text   = FormatCount(rdr["discontinued"]);
                            litHalted.Text         = FormatCount(rdr["halted"]);
                            litDeadYear.Text       = FormatCount(rdr["dead_year"]);
                            litBilled.Text         = FormatCount(rdr["billed"]);
                            litNotBilled.Text      = FormatCount(rdr["not_billed"]);
                        }
                    }
                }
            }
        }
        catch { /* non-fatal */ }
    }

    // ===================================================================
    // BIND GRID
    // ===================================================================

    private void BindGrid()
    {
        string search = (txtSearch.Text ?? "").Trim();
        int pageSize = SafeInt(ddlPageSize.SelectedValue, 50);
        if (pageSize < 25) pageSize = 25;
        if (pageSize > 500) pageSize = 500;

        int page = ParseQueryInt("page", 1, 1, int.MaxValue);

        var fromWhere = new StringBuilder(@"
            FROM acad_registration r
            LEFT JOIN acad_student sreg ON TRIM(sreg.regno) = TRIM(r.regno)
            LEFT JOIN acad_programme preg ON sreg.progid = preg.progcode
            WHERE 1=1");

        var parameters = new List<MySqlParameter>();

        // Year / semester - only filter when not "All"
        string acadYear = ddlAcadYear.SelectedValue;
        string semStr   = ddlSemester.SelectedValue;
        if (!string.IsNullOrEmpty(acadYear)) { fromWhere.Append(" AND r.acad_year = @acadYear"); parameters.Add(new MySqlParameter("@acadYear", acadYear)); }
        if (!string.IsNullOrEmpty(semStr))   { fromWhere.Append(" AND r.semester  = @semester"); parameters.Add(new MySqlParameter("@semester", SafeInt(semStr, 1))); }

        // Other filters
        if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
        {
            fromWhere.Append(" AND r.studyyear = @studyYear");
            parameters.Add(new MySqlParameter("@studyYear", SafeInt(ddlStudyYear.SelectedValue, 0)));
        }
        if (!string.IsNullOrEmpty(ddlRegStatus.SelectedValue))
        {
            fromWhere.Append(" AND r.regstatus = @regStatus");
            parameters.Add(new MySqlParameter("@regStatus", ddlRegStatus.SelectedValue));
        }
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            fromWhere.Append(" AND COALESCE(NULLIF(sreg.progid, ''), '') = @programme");
            parameters.Add(new MySqlParameter("@programme", ddlProgramme.SelectedValue));
        }
        if (!string.IsNullOrEmpty(ddlExamClearance.SelectedValue))
        {
            fromWhere.Append(" AND r.examClearance = @examClear");
            parameters.Add(new MySqlParameter("@examClear", ddlExamClearance.SelectedValue));
        }
        if (!string.IsNullOrEmpty(ddlIDCard.SelectedValue))
        {
            if (ddlIDCard.SelectedValue == "ISSUED")
                fromWhere.Append(" AND r.id_cardStatus = 'ISSUED'");
            else
                fromWhere.Append(" AND (r.id_cardStatus IS NULL OR r.id_cardStatus != 'ISSUED')");
        }
        if (!string.IsNullOrEmpty(ddlResidence.SelectedValue))
        {
            if (ddlResidence.SelectedValue == "RESIDENT")
                fromWhere.Append(" AND r.residence_status = 'RESIDENT'");
            else
                fromWhere.Append(" AND r.residence_status != 'RESIDENT'");
        }
        if (!string.IsNullOrEmpty(ddlBilling.SelectedValue))
        {
            if (ddlBilling.SelectedValue == "BILLED")
                fromWhere.Append(" AND EXISTS(SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE ft.regno=COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno)) AND ft.acadyear=r.acad_year AND ft.semester=r.semester AND ft.trans_type='Bill')");
            else
                fromWhere.Append(" AND NOT EXISTS(SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE ft.regno=COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno)) AND ft.acadyear=r.acad_year AND ft.semester=r.semester AND ft.trans_type='Bill')");
        }
        if (!string.IsNullOrEmpty(search))
        {
            fromWhere.Append(" AND (COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno)) LIKE @search OR TRIM(CONCAT_WS(' ', NULLIF(sreg.firstname, ''), NULLIF(sreg.othername, ''))) LIKE @search OR COALESCE(NULLIF(sreg.progid, ''), '') LIKE @search)");
            parameters.Add(new MySqlParameter("@search", "%" + search + "%"));
        }

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                int totalCount;
                using (var countCmd = new MySqlCommand("SELECT COUNT(*) " + fromWhere, conn))
                {
                    countCmd.CommandTimeout = 45;
                    foreach (var p in parameters)
                        countCmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    totalCount = SafeInt(countCmd.ExecuteScalar(), 0);
                }

                int totalPages = totalCount <= 0 ? 1 : (int)Math.Ceiling((double)totalCount / pageSize);
                if (page > totalPages) page = totalPages;
                int offset = (page - 1) * pageSize;

                var selectSql = new StringBuilder(@"
                    SELECT
                        r.ID,
                        COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno)) AS regno,
                        r.acad_year,
                        r.semester,
                        r.regstatus,
                        r.studyyear,
                        CASE WHEN r.id_cardStatus = 'ISSUED' THEN 'ISSUED' ELSE 'NOT ISSUED' END AS id_cardStatus,
                        CASE WHEN r.residence_status = 'RESIDENT' THEN 'RESIDENT' ELSE 'NON-RESIDENT' END AS residence_status,
                        COALESCE(r.examClearance, 'UNCLEARED')       AS examClearance,
                        CASE WHEN r.examClearanceDate IS NULL OR r.examClearanceDate = '0000-00-00'
                             THEN '' ELSE DATE_FORMAT(r.examClearanceDate,'%d %b %Y') END AS examClearanceDate,
                        COALESCE(r.registeredBy, '') AS registeredBy,
                        COALESCE(r.clearedBy, '')    AS clearedBy,
                        NULLIF(TRIM(CONCAT_WS(' ', NULLIF(sreg.firstname, ''), NULLIF(sreg.othername, ''))), '') AS student_name,
                        COALESCE(NULLIF(sreg.progid, ''), '') AS progcode,
                        COALESCE(NULLIF(preg.progname, ''), '') AS progname,
                        CASE WHEN EXISTS(
                            SELECT 1
                            FROM campus_dynamics_accounts.fin_studentfeestracking ft
                            WHERE ft.regno = COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno))
                              AND ft.acadyear = r.acad_year
                              AND ft.semester = r.semester
                              AND ft.trans_type = 'Bill'
                        ) THEN 'BILLED' ELSE 'NOT BILLED' END AS billing_status,
                        COALESCE((
                            SELECT SUM(ftb.amount)
                            FROM campus_dynamics_accounts.fin_studentfeestracking ftb
                            WHERE ftb.regno = COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno))
                              AND ftb.acadyear = r.acad_year
                              AND ftb.semester = r.semester
                              AND ftb.trans_type = 'Bill'
                        ), 0) AS total_billed,
                        COALESCE((
                            SELECT SUM(ftp.amount)
                            FROM campus_dynamics_accounts.fin_studentfeestracking ftp
                            WHERE ftp.regno = COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno))
                              AND ftp.acadyear = r.acad_year
                              AND ftp.semester = r.semester
                              AND ftp.trans_type = 'Payment'
                        ), 0) AS total_paid
                ");
                selectSql.Append(fromWhere.ToString());
                selectSql.Append(" ORDER BY sreg.firstname, sreg.othername, COALESCE(NULLIF(TRIM(sreg.regno), ''), TRIM(r.regno))");
                selectSql.Append(" LIMIT @offset, @pageSize");

                using (var cmd = new MySqlCommand(selectSql.ToString(), conn))
                {
                    cmd.CommandTimeout = 60;
                    foreach (var p in parameters)
                        cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    cmd.Parameters.AddWithValue("@offset", offset);
                    cmd.Parameters.AddWithValue("@pageSize", pageSize);

                    using (var da = new MySqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);

                        HydrateMissingStudentDetails(dt, conn);

                        lblRecordCount.Text  = totalCount.ToString("N0") + " item" + (totalCount != 1 ? "s" : "");
                        litFooterCount.Text  = string.Format("Page {0} of {1} ({2:N0} items)", page, totalPages, totalCount);
                        litPager.Text        = BuildPagerHtml(page, totalPages);
                        rptRegistrations.DataSource = dt;
                        rptRegistrations.DataBind();
                        pnlNoData.Visible = (dt.Rows.Count == 0);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowToast(false, "Error loading data: " + ex.Message);
        }
    }

    private sealed class StudentFallbackInfo
    {
        public string RegNo;
        public string StudentName;
        public string ProgCode;
        public string ProgName;
    }

    private void HydrateMissingStudentDetails(DataTable table, MySqlConnection conn)
    {
        if (table == null || table.Rows.Count == 0 || conn == null) return;

        var missingEmails = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (DataRow row in table.Rows)
        {
            string studentName = (row["student_name"] == DBNull.Value ? "" : row["student_name"].ToString()).Trim();
            if (!string.IsNullOrEmpty(studentName)) continue;

            string regOrEmail = (row["regno"] == DBNull.Value ? "" : row["regno"].ToString()).Trim();
            if (string.IsNullOrEmpty(regOrEmail) || regOrEmail.IndexOf('@') < 0) continue;

            string key = regOrEmail.ToLowerInvariant();
            if (seen.Add(key)) missingEmails.Add(key);
        }

        if (missingEmails.Count == 0) return;

        var sql = new StringBuilder(@"
            SELECT
                LOWER(TRIM(s.email)) AS email_key,
                TRIM(IFNULL(s.regno, '')) AS regno,
                NULLIF(TRIM(CONCAT_WS(' ', NULLIF(s.firstname, ''), NULLIF(s.othername, ''))), '') AS student_name,
                IFNULL(s.progid, '') AS progcode,
                IFNULL(p.progname, '') AS progname
            FROM acad_student s
            LEFT JOIN acad_programme p ON p.progcode = s.progid
            WHERE IFNULL(s.email, '') <> ''
              AND LOWER(TRIM(s.email)) IN (");

        for (int i = 0; i < missingEmails.Count; i++)
        {
            if (i > 0) sql.Append(",");
            sql.Append("@e").Append(i);
        }
        sql.Append(") ORDER BY s.regno");

        var byEmail = new Dictionary<string, StudentFallbackInfo>(StringComparer.OrdinalIgnoreCase);

        using (var cmd = new MySqlCommand(sql.ToString(), conn))
        {
            cmd.CommandTimeout = 30;
            for (int i = 0; i < missingEmails.Count; i++)
                cmd.Parameters.AddWithValue("@e" + i, missingEmails[i]);

            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    string emailKey = rdr["email_key"].ToString();
                    if (string.IsNullOrEmpty(emailKey) || byEmail.ContainsKey(emailKey)) continue;

                    byEmail[emailKey] = new StudentFallbackInfo
                    {
                        RegNo = rdr["regno"].ToString().Trim(),
                        StudentName = (rdr["student_name"] == DBNull.Value ? "" : rdr["student_name"].ToString().Trim()),
                        ProgCode = rdr["progcode"].ToString().Trim(),
                        ProgName = rdr["progname"].ToString().Trim()
                    };
                }
            }
        }

        if (byEmail.Count == 0) return;

        foreach (DataRow row in table.Rows)
        {
            string studentName = (row["student_name"] == DBNull.Value ? "" : row["student_name"].ToString()).Trim();
            if (!string.IsNullOrEmpty(studentName)) continue;

            string regOrEmail = (row["regno"] == DBNull.Value ? "" : row["regno"].ToString()).Trim();
            if (string.IsNullOrEmpty(regOrEmail)) continue;

            StudentFallbackInfo info;
            if (!byEmail.TryGetValue(regOrEmail.ToLowerInvariant(), out info)) continue;

            if (!string.IsNullOrEmpty(info.StudentName)) row["student_name"] = info.StudentName;
            if (!string.IsNullOrEmpty(info.ProgCode)) row["progcode"] = info.ProgCode;
            if (!string.IsNullOrEmpty(info.ProgName)) row["progname"] = info.ProgName;
            if (!string.IsNullOrEmpty(info.RegNo)) row["regno"] = info.RegNo;
        }
    }

    // ===================================================================
    // TEMPLATE HELPERS - visibility in DataItemTemplate
    // ===================================================================

    protected string ShowIf(object val, string match)
    {
        return val != null && val.ToString().Equals(match, StringComparison.OrdinalIgnoreCase)
            ? "" : "display:none;";
    }
    protected string ShowIfIn(object val, string options)
    {
        if (val == null) return "display:none;";
        foreach (var opt in options.Split('|'))
            if (opt.Trim().Equals(val.ToString().Trim(), StringComparison.OrdinalIgnoreCase))
                return "";
        return "display:none;";
    }
    protected string ShowIfNot(object val, string match)
    {
        return val == null || !val.ToString().Equals(match, StringComparison.OrdinalIgnoreCase)
            ? "" : "display:none;";
    }
    protected string ShowIfNotIn(object val, string options)
    {
        if (val == null) return "";
        foreach (var opt in options.Split('|'))
            if (opt.Trim().Equals(val.ToString().Trim(), StringComparison.OrdinalIgnoreCase))
                return "display:none;";
        return "";
    }

    protected string GetRowClass(string status)
    {
        switch ((status ?? "").ToUpper().Trim())
        {
            case "LATE REGISTERED": return "sr-row--late";
            case "CLEARED":         return "sr-row--cleared";
            case "DISCONTINUED":    return "sr-row--discont";
            case "HALTED":          return "sr-row--halted";
            case "DEAD YEAR":       return "sr-row--dead";
            default:                return "";
        }
    }

    protected string GetStatusClass(string s)
    {
        switch ((s ?? "").ToUpper().Trim())
        {
            case "UNREGISTERED":    return "unreg";
            case "REGISTERED":      return "reg";
            case "LATE REGISTERED": return "late";
            case "CLEARED":         return "cleared";
            case "DISCONTINUED":    return "discont";
            case "HALTED":          return "halted";
            case "DEAD YEAR":       return "dead";
            default:                return "unreg";
        }
    }
    protected string GetClearanceClass(string s)
    {
        switch ((s ?? "").ToUpper().Trim())
        {
            case "CLEARED":   return "cleared";
            case "PRINTED":   return "printed";
            default:          return "uncleared";
        }
    }
    protected string GetIDCardClass(string s)
    {
        switch ((s ?? "").ToUpper().Trim())
        {
            case "ISSUED":
            case "PRINTED": return "issued";
            default:        return "notissued";
        }
    }
    protected string GetBillingClass(string s)
    {
        return (s ?? "").ToUpper().Trim() == "BILLED" ? "billed" : "notbilled";
    }

    // ===================================================================
    // FILTER CHANGE HANDLERS
    // ===================================================================

    protected void btnSearch_Click(object sender, EventArgs e)                   { RedirectToList(1); }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)   { RedirectToList(1); }
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)   { RedirectToList(1); }
    protected void ddlStudyYear_SelectedIndexChanged(object sender, EventArgs e)  { RedirectToList(1); }
    protected void ddlRegStatus_SelectedIndexChanged(object sender, EventArgs e)  { RedirectToList(1); }
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)  { RedirectToList(1); }
    protected void ddlExamClearance_SelectedIndexChanged(object sender, EventArgs e) { RedirectToList(1); }
    protected void ddlIDCard_SelectedIndexChanged(object sender, EventArgs e)     { RedirectToList(1); }
    protected void ddlResidence_SelectedIndexChanged(object sender, EventArgs e)  { RedirectToList(1); }
    protected void ddlBilling_SelectedIndexChanged(object sender, EventArgs e)    { RedirectToList(1); }
    protected void txtSearch_TextChanged(object sender, EventArgs e)              { /* handled by btnSearch_Click */ }
    protected void ddlPageSize_Changed(object sender, EventArgs e)               { RedirectToList(1); }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        RedirectCleanList();
    }
    protected void btnRefresh_Click(object sender, EventArgs e) { LoadStats(); BindGrid(); }

    // ===================================================================
    // INDIVIDUAL ACTIONS
    // ===================================================================

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        ShowToast(false, "Semester registration is now student self-service. Students must register through the student portal.");
        LoadStats(); BindGrid();
    }

    protected void btnLateRegister_Click(object sender, EventArgs e)
    {
        ShowToast(false, "Semester registration is now student self-service. Students must register through the student portal.");
        LoadStats(); BindGrid();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        if (ClearStudent(id))
            ShowToast(true, "Student cleared for exams.");
        else
            ShowToast(false, "Could not clear student. They must be Registered or Late Registered first.");
        LoadStats(); BindGrid();
    }

    protected void btnUndoClear_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = @"UPDATE acad_registration
                    SET regstatus='REGISTERED', examClearance='UNCLEARED',
                        examClearanceDate=NULL, clearedBy=NULL
                    WHERE ID=@id AND examClearance='CLEARED'";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    ShowToast(ok, ok ? "Exam clearance undone. Student reverted to Registered."
                                    : "Could not undo clearance.");
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Error: " + ex.Message); }
        LoadStats(); BindGrid();
    }

    protected void btnUnregister_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = @"UPDATE acad_registration
                    SET regstatus='UNREGISTERED', registeredBy=NULL
                    WHERE ID=@id AND regstatus IN ('REGISTERED','LATE REGISTERED')";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    ShowToast(ok, ok ? "Registration undone." : "Could not undo registration.");
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Error: " + ex.Message); }
        LoadStats(); BindGrid();
    }

    protected void btnDiscontinue_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        if (ForceStatus(id, "DISCONTINUED"))
            ShowToast(true, "Student marked as Discontinued.");
        else
            ShowToast(false, "Could not update status.");
        LoadStats(); BindGrid();
    }

    protected void btnHalt_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        if (ForceStatus(id, "HALTED"))
            ShowToast(true, "Student registration halted.");
        else
            ShowToast(false, "Could not halt registration.");
        LoadStats(); BindGrid();
    }

    protected void btnDeadYear_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        if (ForceStatus(id, "DEAD YEAR"))
            ShowToast(true, "Marked as Dead Year.");
        else
            ShowToast(false, "Could not update status.");
        LoadStats(); BindGrid();
    }

    protected void btnReactivate_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = @"UPDATE acad_registration
                    SET regstatus='UNREGISTERED', registeredBy=NULL, examClearance='UNCLEARED'
                    WHERE ID=@id AND regstatus IN ('DISCONTINUED','HALTED','DEAD YEAR')";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    ShowToast(ok, ok ? "Student reactivated to Unregistered." : "Could not reactivate student.");
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Error: " + ex.Message); }
        LoadStats(); BindGrid();
    }

    protected void btnIssueIDCard_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = "UPDATE acad_registration SET id_cardStatus='ISSUED' WHERE ID=@id";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    ShowToast(ok, ok ? "ID card marked as Issued." : "Could not update ID card status.");
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Error: " + ex.Message); }
        BindGrid();
    }

    protected void btnRevokeIDCard_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = "UPDATE acad_registration SET id_cardStatus='NOT ISSUED' WHERE ID=@id";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    ShowToast(ok, ok ? "ID card revoked." : "Could not revoke ID card.");
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Error: " + ex.Message); }
        BindGrid();
    }

    // ===================================================================
    // DELETE REGISTRATION
    // ===================================================================

    protected void btnDeleteReg_Click(object sender, EventArgs e)
    {
        int id = GetLinkButtonID(sender);
        if (id <= 0) return;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // Fetch the record details for the activity log
                string regno = "", acadYear = "";
                int semester = 0;
                using (var cmd = new MySqlCommand(
                    "SELECT regno, acad_year, semester FROM acad_registration WHERE ID=@id LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            regno    = rdr["regno"].ToString();
                            acadYear = rdr["acad_year"].ToString();
                            semester = Convert.ToInt32(rdr["semester"]);
                        }
                    }
                }

                if (string.IsNullOrEmpty(regno))
                {
                    ShowToast(false, "Registration record not found.");
                    return;
                }

                // Delete the registration record
                using (var cmd = new MySqlCommand("DELETE FROM acad_registration WHERE ID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    if (ok)
                    {
                        // Log the deletion
                        using (var logCmd = new MySqlCommand(
                            "INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date) VALUES (@usr, 'Delete Registration', @par, 'Deleted registration record', NOW())", conn))
                        {
                            logCmd.Parameters.AddWithValue("@usr", GetCurrentUser());
                            logCmd.Parameters.AddWithValue("@par", string.Format("{0} | {1} Sem {2}", regno, acadYear, semester));
                            logCmd.ExecuteNonQuery();
                        }
                        ShowToast(true, string.Format("Registration deleted for {0} ({1} Sem {2}).", regno, acadYear, semester));
                    }
                    else
                    {
                        ShowToast(false, "Could not delete registration record.");
                    }
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Delete failed: " + ex.Message); }
        LoadStats(); BindGrid();
    }

    // ===================================================================
    // BATCH ACTIONS
    // ===================================================================

    protected void btnBatchRegister_Click(object sender, EventArgs e)          { RunBatch("register");     }
    protected void btnBatchLateRegister_Click(object sender, EventArgs e)      { RunBatch("late");         }
    protected void btnBatchClear_Click(object sender, EventArgs e)             { RunBatch("clear");        }
    protected void btnBatchUndoReg_Click(object sender, EventArgs e)           { RunBatch("undoreg");      }
    protected void btnBatchUndoClear_Click(object sender, EventArgs e)         { RunBatch("undoclear");    }
    protected void btnBatchDiscontinue_Click(object sender, EventArgs e)       { RunBatch("discontinue"); }
    protected void btnBatchHalt_Click(object sender, EventArgs e)              { RunBatch("halt");         }
    protected void btnBatchDeadYear_Click(object sender, EventArgs e)          { RunBatch("deadyear");     }
    protected void btnBatchReactivate_Click(object sender, EventArgs e)        { RunBatch("reactivate");   }
    protected void btnBatchDelete_Click(object sender, EventArgs e)             { RunBatch("delete");       }

    private void RunBatch(string action)
    {
        if (action == "register" || action == "late")
        {
            ShowToast(false, "Semester registration is now student self-service. Students must register through the student portal.");
            return;
        }
        string idsRaw = (hdnBatchIds.Value ?? "").Trim();
        hdnBatchIds.Value = "";
        if (string.IsNullOrEmpty(idsRaw))
        {
            ShowToast(false, "No students selected.");
            return;
        }
        var idList = new List<int>();
        foreach (string s in idsRaw.Split(','))
        {
            int id;
            if (int.TryParse(s.Trim(), out id) && id > 0)
                idList.Add(id);
        }
        if (idList.Count == 0)
        {
            ShowToast(false, "No students selected.");
            return;
        }
        int processed = 0, skipped = 0;
        foreach (int id in idList)
        {
            bool ok = false;
            switch (action)
            {
                case "register":    break;
                case "late":        break;
                case "clear":       ok = ClearStudent(id);  break;
                case "undoreg":     ok = BatchUndoReg(id);  break;
                case "undoclear":   ok = BatchUndoClear(id); break;
                case "discontinue": ok = ForceStatus(id, "DISCONTINUED"); break;
                case "halt":        ok = ForceStatus(id, "HALTED");       break;
                case "deadyear":    ok = ForceStatus(id, "DEAD YEAR");    break;
                case "reactivate":  ok = BatchReactivate(id);             break;
                case "delete":      ok = BatchDeleteReg(id);              break;
            }
            if (ok) processed++; else skipped++;
        }
        string msg = processed + (action == "delete" ? " registration(s) deleted." : " student(s) updated.");
        if (skipped > 0) msg += " " + skipped + " skipped.";
        ShowToast(processed > 0, msg);
        LoadStats();
        BindGrid();
    }

    // ===================================================================
    // ADD REGISTRATION MODAL
    // ===================================================================

    protected void btnDoAddReg_Click(object sender, EventArgs e)
    {
        string regno     = (txtAddRegNo.Text ?? "").Trim();
        string acadYear  = ddlAddAcadYear.SelectedValue;
        int    semester  = SafeInt(ddlAddSemester.SelectedValue, 1);
        int    studyYear = SafeInt(ddlAddStudyYear.SelectedValue, 1);
        string status    = ddlAddStatus.SelectedValue;
        string residence = ddlAddResidence.SelectedValue;

        if (string.IsNullOrEmpty(regno))
        {
            ShowAddRegError("Please enter a registration number.");
            return;
        }
        if (string.IsNullOrEmpty(acadYear))
        {
            ShowAddRegError("Please select an academic year.");
            return;
        }
        if (semester < 1 || semester > 3)
        {
            ShowAddRegError("Please select a valid semester.");
            return;
        }

        if (status == "REGISTERED" || status == "LATE REGISTERED")
        {
            ShowAddRegError("Semester registration is now student self-service. Students must register through the student portal.");
            return;
        }

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // Check student exists
                long sc = 0;
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE regno=@r", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    sc = (long)cmd.ExecuteScalar();
                }
                if (sc == 0)
                {
                    ShowAddRegError("Student with registration number \"" + Server.HtmlEncode(regno) + "\" was not found in student records.");
                    return;
                }

                // Check duplicate
                long dc = 0;
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_registration WHERE regno=@r AND acad_year=@y AND semester=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    cmd.Parameters.AddWithValue("@y", acadYear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    dc = (long)cmd.ExecuteScalar();
                }
                if (dc > 0)
                {
                    ShowAddRegError(string.Format(
                        "Student {0} already has a registration record for {1}, Semester {2}. Duplicate entries are not allowed.",
                        Server.HtmlEncode(regno), acadYear, semester));
                    return;
                }

                // Insert
                const string insertSql = @"
                    INSERT INTO acad_registration
                        (regno, acad_year, semester, studyyear, regstatus,
                         id_cardStatus, residence_status, examClearance, registeredBy)
                    VALUES
                        (@regno, @year, @sem, @studyYear, @status,
                         'UNPRINTED', @res, 'UNCLEARED', @user)";
                using (var cmd = new MySqlCommand(insertSql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno",     regno);
                    cmd.Parameters.AddWithValue("@year",      acadYear);
                    cmd.Parameters.AddWithValue("@sem",       semester);
                    cmd.Parameters.AddWithValue("@studyYear", studyYear);
                    cmd.Parameters.AddWithValue("@status",    status);
                    cmd.Parameters.AddWithValue("@res",       residence);
                    cmd.Parameters.AddWithValue("@user",      GetCurrentUser());
                    cmd.ExecuteNonQuery();
                }

                // Auto-bill if status is REGISTERED or LATE REGISTERED
                if (status == "REGISTERED" || status == "LATE REGISTERED")
                {
                    long newId = 0;
                    using (var cmd2 = new MySqlCommand(
                        "SELECT ID FROM acad_registration WHERE regno=@r AND acad_year=@y AND semester=@s LIMIT 1", conn))
                    {
                        cmd2.Parameters.AddWithValue("@r", regno);
                        cmd2.Parameters.AddWithValue("@y", acadYear);
                        cmd2.Parameters.AddWithValue("@s", semester);
                        object val = cmd2.ExecuteScalar();
                        if (val != null) newId = Convert.ToInt64(val);
                    }
                    if (newId > 0)
                    {
                        string billWarn = AutoBillStudent((int)newId);
                        if (!string.IsNullOrEmpty(billWarn))
                            ScriptManager.RegisterStartupScript(this, GetType(), "billWarn",
                                "setTimeout(function(){showToast(false,'" + billWarn.Replace("'", "\\'") + "');},600);", true);
                    }
                }
            }

            // Close modal and show toast
            ScriptManager.RegisterStartupScript(this, GetType(), "closeAdd", "closeModal('addRegModal');", true);
            txtAddRegNo.Text = "";
            ShowToast(true, "Registration record added for " + regno + ".");
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowAddRegError("Unexpected error: " + ex.Message);
        }
    }

    private void ShowAddRegError(string msg)
    {
        addRegResult.Visible    = true;
        addRegResult.Attributes["class"] = "hr-result hr-result--err";
        litAddRegResult.Text    = Server.HtmlEncode(msg);
        // Re-open modal WITHOUT hiding the error div
        ScriptManager.RegisterStartupScript(this, GetType(), "reopenAdd",
            "document.getElementById('addRegModal').classList.add('open');", true);
    }

    // ===================================================================
    // CHANGE STATUS MODAL
    // ===================================================================

    protected void btnDoChangeStatus_Click(object sender, EventArgs e)
    {
        int id = SafeInt(hdnCSID.Value, 0);
        if (id <= 0) { ShowToast(false, "Invalid record ID."); return; }

        string newStatus = ddlNewStatus.SelectedValue;
        if (string.IsNullOrEmpty(newStatus)) { ShowToast(false, "Please select a status."); return; }

        if (newStatus == "REGISTERED" || newStatus == "LATE REGISTERED")
        {
            ShowToast(false, "Semester registration is now student self-service. Students must register through the student portal.");
            return;
        }

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "UPDATE acad_registration SET regstatus=@s WHERE ID=@id";
                // Also clear/set related fields based on new status
                if (newStatus == "CLEARED")
                    sql = "UPDATE acad_registration SET regstatus=@s, examClearance='CLEARED', examClearanceDate=NOW(), clearedBy=@user WHERE ID=@id";
                else if (newStatus == "REGISTERED" || newStatus == "LATE REGISTERED")
                    sql = "UPDATE acad_registration SET regstatus=@s, registeredBy=@user WHERE ID=@id";
                else if (newStatus == "UNREGISTERED")
                    sql = "UPDATE acad_registration SET regstatus=@s, registeredBy=NULL, examClearance='UNCLEARED' WHERE ID=@id";

                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s",    newStatus);
                    cmd.Parameters.AddWithValue("@id",   id);
                    cmd.Parameters.AddWithValue("@user", GetCurrentUser());
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    if (ok && (newStatus == "REGISTERED" || newStatus == "LATE REGISTERED"))
                        AutoBillStudent(id);
                    ScriptManager.RegisterStartupScript(this, GetType(), "closecs", "closeModal('changeStatusModal');", true);
                    ShowToast(ok, ok ? "Status changed to " + newStatus + "." : "No changes made.");
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Error: " + ex.Message); }
        LoadStats();
        BindGrid();
    }

    // ===================================================================
    // EXPORT CSV
    // ===================================================================

    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semStr   = ddlSemester.SelectedValue;
        string search   = (txtSearch.Text ?? "").Trim();

        var sb = new StringBuilder(@"
            SELECT
                COALESCE(NULLIF(TRIM(sreg.regno), ''), NULLIF(TRIM(semail.regno), ''), TRIM(r.regno)) AS regno,
                NULLIF(TRIM(CONCAT_WS(' ', NULLIF(COALESCE(sreg.firstname, semail.firstname), ''), NULLIF(COALESCE(sreg.othername, semail.othername), ''))), '') AS student_name,
                COALESCE(NULLIF(sreg.progid, ''), NULLIF(semail.progid, ''), '') AS progcode,
                COALESCE(NULLIF(preg.progname, ''), NULLIF(pemail.progname, ''), '') AS progname,
                r.studyyear, r.regstatus,
                COALESCE(r.examClearance,'UNCLEARED') AS examClearance,
                CASE WHEN r.id_cardStatus = 'ISSUED' THEN 'ISSUED' ELSE 'NOT ISSUED' END AS id_cardStatus,
                CASE WHEN r.residence_status = 'RESIDENT' THEN 'RESIDENT' ELSE 'NON-RESIDENT' END AS residence_status,
                COALESCE(r.registeredBy,'') AS registeredBy,
                COALESCE(r.clearedBy,'') AS clearedBy,
                CASE WHEN r.examClearanceDate IS NULL OR r.examClearanceDate='0000-00-00'
                     THEN '' ELSE DATE_FORMAT(r.examClearanceDate,'%Y-%m-%d') END AS examClearanceDate,
                r.acad_year, r.semester,
                CASE WHEN b.bill_count > 0 THEN 'BILLED' ELSE 'NOT BILLED' END AS billing_status,
                COALESCE(b.total_billed, 0) AS total_billed,
                COALESCE(b.total_paid, 0)   AS total_paid
            FROM acad_registration r
            LEFT JOIN acad_student sreg ON TRIM(sreg.regno)=TRIM(r.regno)
            LEFT JOIN (
                SELECT LOWER(TRIM(email)) AS email_key, MIN(regno) AS regno
                FROM acad_student
                WHERE IFNULL(email, '') <> ''
                GROUP BY LOWER(TRIM(email))
                HAVING COUNT(*) = 1
            ) su ON su.email_key = LOWER(TRIM(r.regno))
            LEFT JOIN acad_student semail ON semail.regno = su.regno
            LEFT JOIN acad_programme preg ON sreg.progid=preg.progcode
            LEFT JOIN acad_programme pemail ON semail.progid=pemail.progcode
            LEFT JOIN (
                SELECT regno, acadyear, semester,
                    COUNT(CASE WHEN trans_type='Bill' THEN 1 END) AS bill_count,
                    SUM(CASE WHEN trans_type='Bill' THEN amount ELSE 0 END) AS total_billed,
                    SUM(CASE WHEN trans_type='Payment' THEN amount ELSE 0 END) AS total_paid
                FROM campus_dynamics_accounts.fin_studentfeestracking
                GROUP BY regno, acadyear, semester
            ) b ON b.regno=COALESCE(NULLIF(TRIM(sreg.regno), ''), NULLIF(TRIM(semail.regno), ''), TRIM(r.regno))
               AND b.acadyear=r.acad_year AND b.semester=r.semester
            WHERE 1=1");

        var parameters = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(acadYear)) { sb.Append(" AND r.acad_year=@acadYear"); parameters.Add(new MySqlParameter("@acadYear", acadYear)); }
        if (!string.IsNullOrEmpty(semStr))   { sb.Append(" AND r.semester=@semester");  parameters.Add(new MySqlParameter("@semester", SafeInt(semStr, 1))); }
        if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))     { sb.Append(" AND r.studyyear=@sy"); parameters.Add(new MySqlParameter("@sy", SafeInt(ddlStudyYear.SelectedValue, 0))); }
        if (!string.IsNullOrEmpty(ddlRegStatus.SelectedValue))     { sb.Append(" AND r.regstatus=@rs"); parameters.Add(new MySqlParameter("@rs", ddlRegStatus.SelectedValue)); }
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))     { sb.Append(" AND COALESCE(NULLIF(sreg.progid, ''), NULLIF(semail.progid, ''))=@prog"); parameters.Add(new MySqlParameter("@prog", ddlProgramme.SelectedValue)); }
        if (!string.IsNullOrEmpty(ddlExamClearance.SelectedValue)) { sb.Append(" AND r.examClearance=@ec"); parameters.Add(new MySqlParameter("@ec", ddlExamClearance.SelectedValue)); }
        if (!string.IsNullOrEmpty(ddlIDCard.SelectedValue))        { if (ddlIDCard.SelectedValue == "ISSUED") sb.Append(" AND r.id_cardStatus='ISSUED'"); else sb.Append(" AND (r.id_cardStatus IS NULL OR r.id_cardStatus!='ISSUED')"); }
        if (!string.IsNullOrEmpty(ddlResidence.SelectedValue))     { if (ddlResidence.SelectedValue == "RESIDENT") sb.Append(" AND r.residence_status='RESIDENT'"); else sb.Append(" AND r.residence_status!='RESIDENT'"); }
        if (!string.IsNullOrEmpty(ddlBilling.SelectedValue))        { if (ddlBilling.SelectedValue == "BILLED") sb.Append(" AND EXISTS(SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE ft.regno=COALESCE(NULLIF(TRIM(sreg.regno), ''), NULLIF(TRIM(semail.regno), ''), TRIM(r.regno)) AND ft.acadyear=r.acad_year AND ft.semester=r.semester AND ft.trans_type='Bill')"); else sb.Append(" AND NOT EXISTS(SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE ft.regno=COALESCE(NULLIF(TRIM(sreg.regno), ''), NULLIF(TRIM(semail.regno), ''), TRIM(r.regno)) AND ft.acadyear=r.acad_year AND ft.semester=r.semester AND ft.trans_type='Bill')"); }
        if (!string.IsNullOrEmpty(search))                         { sb.Append(" AND (COALESCE(NULLIF(TRIM(sreg.regno), ''), NULLIF(TRIM(semail.regno), ''), TRIM(r.regno)) LIKE @s OR TRIM(CONCAT_WS(' ', NULLIF(COALESCE(sreg.firstname, semail.firstname), ''), NULLIF(COALESCE(sreg.othername, semail.othername), ''))) LIKE @s)"); parameters.Add(new MySqlParameter("@s", "%" + search + "%")); }
        sb.Append(" ORDER BY COALESCE(sreg.firstname, semail.firstname), COALESCE(sreg.othername, semail.othername), COALESCE(NULLIF(TRIM(sreg.regno), ''), NULLIF(TRIM(semail.regno), ''), TRIM(r.regno))");

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sb.ToString(), conn))
                {
                    foreach (var p in parameters) cmd.Parameters.Add(p);
                    using (var da = new MySqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);

                        var csv = new StringBuilder();
                        csv.AppendLine("Reg No,Student Name,Programme Code,Programme Name,Study Year,Reg Status,Exam Clearance,ID Card,Residence,Billing Status,Total Billed,Total Paid,Registered By,Cleared By,Clearance Date,Academic Year,Semester");
                        foreach (DataRow row in dt.Rows)
                        {
                            csv.AppendLine(string.Join(",",
                                CsvEsc(row["regno"]), CsvEsc(row["student_name"]),
                                CsvEsc(row["progcode"]), CsvEsc(row["progname"]),
                                CsvEsc(row["studyyear"]), CsvEsc(row["regstatus"]),
                                CsvEsc(row["examClearance"]), CsvEsc(row["id_cardStatus"]),
                                CsvEsc(row["residence_status"]),
                                CsvEsc(row["billing_status"]),
                                CsvEsc(row["total_billed"]), CsvEsc(row["total_paid"]),
                                CsvEsc(row["registeredBy"]),
                                CsvEsc(row["clearedBy"]), CsvEsc(row["examClearanceDate"]),
                                CsvEsc(row["acad_year"]), CsvEsc(row["semester"])));
                        }

                        string yearPart = string.IsNullOrEmpty(acadYear) ? "all" : acadYear.Replace("/", "_");
                        string semPart  = string.IsNullOrEmpty(semStr)   ? "all" : "sem" + semStr;
                        string filename = string.Format("registration_{0}_{1}.csv", yearPart, semPart);
                        Response.Clear();
                        Response.ContentType = "text/csv";
                        Response.AddHeader("Content-Disposition", "attachment; filename=" + filename);
                        Response.Write(csv.ToString());
                        Response.End();
                    }
                }
            }
        }
        catch (Exception ex) { ShowToast(false, "Export failed: " + ex.Message); }
    }

    private string CsvEsc(object val)
    {
        string s = (val == null || val == DBNull.Value) ? "" : val.ToString();
        if (s.Contains(",") || s.Contains("\"") || s.Contains("\n"))
            return "\"" + s.Replace("\"", "\"\"") + "\"";
        return s;
    }

    // ===================================================================
    // DATABASE OPERATION PRIMITIVES
    // ===================================================================

    /// <summary>
    /// Sets regstatus to newStatus and updates an auditing column, but only if the
    /// current regstatus matches the allowed value.
    /// </summary>
    private bool DoSetStatus(int id, string newStatus, string auditCol, string condCol, string condVal)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = string.Format(
                    "UPDATE acad_registration SET regstatus=@s, {0}=@user WHERE ID=@id AND {1}=@cond",
                    auditCol, condCol);
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s",    newStatus);
                    cmd.Parameters.AddWithValue("@user", GetCurrentUser());
                    cmd.Parameters.AddWithValue("@id",   id);
                    cmd.Parameters.AddWithValue("@cond", condVal);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch { return false; }
    }

    /// <summary>
    /// Auto-bill a student after registration. Safe to call multiple times —
    /// fin_TermlyItemBillingFN has a pre-check that skips already-billed items.
    /// Returns null on success (or already billed). Returns a warning string
    /// when billing could not be confirmed — registration is never blocked.
    /// Failures are also logged to fin_billing_errors for admin review.
    /// </summary>
    private string AutoBillStudent(int regId)
    {
        string regno = "", acadYear = "";
        int semester = 0;
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT regno, acad_year, semester FROM acad_registration WHERE ID=@id LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", regId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) return null;
                        regno    = rdr["regno"].ToString();
                        acadYear = rdr["acad_year"].ToString();
                        semester = Convert.ToInt32(rdr["semester"]);
                    }
                }
            }
            if (string.IsNullOrEmpty(regno)) return null;

            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand("fin_AutoBillOnRegistration", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.AddWithValue("@p_regno",    regno);
                    cmd.Parameters.AddWithValue("@p_acadyear", acadYear);
                    cmd.Parameters.AddWithValue("@p_semester",  semester);
                    cmd.Parameters.AddWithValue("@p_user",     GetCurrentUser());
                    using (var rdr = cmd.ExecuteReader()) { while (rdr.NextResult()) { } }
                }

                using (var chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM fin_studentfeestracking WHERE TRIM(regno)=TRIM(@r) AND acadyear=@a AND semester=@s AND trans_type='Bill'", conn))
                {
                    chk.Parameters.AddWithValue("@r", regno);
                    chk.Parameters.AddWithValue("@a", acadYear);
                    chk.Parameters.AddWithValue("@s", semester);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        return null;
                }
            }

            string warn = "Billing could not be confirmed for " + regno + " (" + acadYear + " Sem " + semester + "). Please use Fix Billing or Bill Student to complete.";
            LogBillingError(regno, acadYear, semester, warn, "AutoBill-NoRows");
            return warn;
        }
        catch (Exception ex)
        {
            string warn = "Auto-billing failed for " + regno + " (" + acadYear + " Sem " + semester + "): " + ex.Message;
            try { LogBillingError(regno, acadYear, semester, warn, "AutoBill-Exception"); } catch { }
            return warn;
        }
    }

    private void LogBillingError(string regno, string acadYear, int semester, string message, string source)
    {
        try
        {
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"INSERT IGNORE INTO fin_billing_errors (regno, acad_year, semester, triggered_by, trigger_source, error_message)
                      VALUES (@r, @a, @s, @u, @src, @msg)", conn))
                {
                    cmd.Parameters.AddWithValue("@r",   regno ?? "");
                    cmd.Parameters.AddWithValue("@a",   acadYear ?? "");
                    cmd.Parameters.AddWithValue("@s",   semester);
                    cmd.Parameters.AddWithValue("@u",   GetCurrentUser() ?? "SYSTEM");
                    cmd.Parameters.AddWithValue("@src", source ?? "AutoBill");
                    cmd.Parameters.AddWithValue("@msg", message ?? "");
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    // ===================================================================
    // REGISTER ALL — AJAX HANDLERS (preview + batch processing)
    // ===================================================================

    /// <summary>
    /// Intercepts AJAX requests via ?action= querystring.
    /// Returns true (short-circuit Page_Load) if an AJAX action was handled.
    /// </summary>
    private bool HandleAjaxRequest()
    {
        string action = Request.QueryString["action"];
        if (string.IsNullOrEmpty(action)) return false;

        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        try
        {
            switch (action)
            {
                case "preview_register_all": HandlePreviewRegisterAll(); break;
                case "register_batch":       HandleRegisterBatch();      break;
                default: Response.Write("{\"error\":\"Unknown action\"}"); break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEncode(ex.Message) + "\"}");
        }
        try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
        return true;
    }

    /// <summary>
    /// Returns JSON preview: student list, programme breakdown, year breakdown
    /// for UNREGISTERED + ACTIVE students in current year+semester.
    /// </summary>
    private void HandlePreviewRegisterAll()
    {
        // Admin registration disabled — students self-register via the portal
        Response.Write("{\"error\":\"Semester registration is now student self-service. Students must register through the student portal.\"}");
        return;
        string curYear = AcademicYearHelper.GetCurrentAcademicYear();
        int curSem = AcademicYearHelper.GetCurrentSemester();
        if (string.IsNullOrEmpty(curYear) || curSem < 1)
        {
            Response.Write("{\"error\":\"Could not determine current academic year/semester.\"}");
            return;
        }

        var sb = new StringBuilder();
        sb.Append("{");
        sb.AppendFormat("\"acadYear\":\"{0}\",\"semester\":{1},", JsEncode(curYear), curSem);

        var allIds = new List<int>();
        var students = new List<string>();
        var progCounts = new Dictionary<string, int>();
        var yearCounts = new Dictionary<int, int>();

        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            const string sql = @"
                SELECT r.ID, r.regno,
                       TRIM(CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,''))) AS fullname,
                       IFNULL(p.progname, s.progid) AS programme,
                       r.studyyear
                FROM acad_registration r
                INNER JOIN acad_student s ON s.regno = r.regno AND s.new_status = 'ACTIVE'
                LEFT JOIN acad_programme p ON p.progcode = s.progid
                WHERE r.acad_year = @ay AND r.semester = @sem
                  AND r.regstatus = 'UNREGISTERED'
                ORDER BY p.progname, s.firstname, s.othername";
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ay", curYear);
                cmd.Parameters.AddWithValue("@sem", curSem);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        int id = Convert.ToInt32(rdr["ID"]);
                        string prog = rdr["programme"].ToString().Trim();
                        int yr = 0;
                        int.TryParse(rdr["studyyear"].ToString(), out yr);

                        allIds.Add(id);

                        if (!progCounts.ContainsKey(prog)) progCounts[prog] = 0;
                        progCounts[prog]++;
                        if (!yearCounts.ContainsKey(yr)) yearCounts[yr] = 0;
                        yearCounts[yr]++;

                        // Preview detail limited to 200 rows
                        if (students.Count < 200)
                        {
                            students.Add(string.Format(
                                "{{\"id\":{0},\"r\":\"{1}\",\"n\":\"{2}\",\"p\":\"{3}\",\"y\":{4}}}",
                                id,
                                JsEncode(rdr["regno"].ToString().Trim()),
                                JsEncode(rdr["fullname"].ToString().Trim()),
                                JsEncode(prog),
                                yr));
                        }
                    }
                }
            }
        }

        sb.AppendFormat("\"totalCount\":{0},", allIds.Count);

        // IDs for processing
        sb.Append("\"ids\":[");
        for (int i = 0; i < allIds.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append(allIds[i]);
        }
        sb.Append("],");

        // Programme breakdown
        sb.Append("\"byProgramme\":[");
        int pi = 0;
        foreach (var kv in progCounts)
        {
            if (pi++ > 0) sb.Append(",");
            sb.AppendFormat("{{\"p\":\"{0}\",\"c\":{1}}}", JsEncode(kv.Key), kv.Value);
        }
        sb.Append("],");

        // Year breakdown
        sb.Append("\"byYear\":[");
        int yi = 0;
        foreach (var kv in yearCounts)
        {
            if (yi++ > 0) sb.Append(",");
            sb.AppendFormat("{{\"y\":{0},\"c\":{1}}}", kv.Key, kv.Value);
        }
        sb.Append("],");

        // Students preview
        sb.Append("\"students\":[");
        sb.Append(string.Join(",", students.ToArray()));
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    /// <summary>
    /// Processes a batch of registration IDs: registers + auto-bills each.
    /// Accepts POST body: {"ids":[1,2,3,...]}
    /// Returns JSON: {registered, billed, errors, results:[{id,s}]}
    /// </summary>
    private void HandleRegisterBatch()
    {
        // Admin registration disabled — students self-register via the portal
        Response.Write("{\"error\":\"Semester registration is now student self-service. Students must register through the student portal.\"}");
        return;
        string body;
        using (var reader = new StreamReader(Request.InputStream))
        {
            body = reader.ReadToEnd();
        }

        // Parse ids from JSON body: {"ids":[1,2,3]}
        int idsStart = body.IndexOf('[');
        int idsEnd = body.IndexOf(']');
        if (idsStart < 0 || idsEnd < 0 || idsEnd <= idsStart)
        {
            Response.Write("{\"error\":\"Invalid request body\"}");
            return;
        }
        string idsStr = body.Substring(idsStart + 1, idsEnd - idsStart - 1);
        var ids = new List<int>();
        foreach (string s in idsStr.Split(','))
        {
            int id;
            if (int.TryParse(s.Trim(), out id)) ids.Add(id);
        }
        if (ids.Count == 0) { Response.Write("{\"registered\":0,\"billed\":0,\"errors\":0,\"results\":[]}"); return; }

        string user = GetCurrentUser();
        int registered = 0, billed = 0, errors = 0;
        var results = new List<string>();

        foreach (int id in ids)
        {
            try
            {
                bool regOk = false;
                using (var conn = new MySqlConnection(ConnectionString))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand(
                        @"UPDATE acad_registration SET regstatus='REGISTERED', registeredBy=@user
                          WHERE ID=@id AND regstatus='UNREGISTERED'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.Parameters.AddWithValue("@user", user);
                        regOk = cmd.ExecuteNonQuery() > 0;
                    }
                }
                if (regOk)
                {
                    registered++;
                    string billWarn = AutoBillStudent(id);
                    if (string.IsNullOrEmpty(billWarn))
                    {
                        billed++;
                        results.Add(string.Format("{{\"id\":{0},\"s\":\"ok\"}}", id));
                    }
                    else
                    {
                        results.Add(string.Format("{{\"id\":{0},\"s\":\"reg_ok_bill_warn\",\"m\":\"{1}\"}}", id, JsEncode(billWarn)));
                    }
                }
                else
                {
                    results.Add(string.Format("{{\"id\":{0},\"s\":\"skip\"}}", id));
                }
            }
            catch (Exception ex)
            {
                errors++;
                results.Add(string.Format("{{\"id\":{0},\"s\":\"error\",\"m\":\"{1}\"}}", id, JsEncode(ex.Message)));
            }
        }

        Response.Write(string.Format(
            "{{\"registered\":{0},\"billed\":{1},\"errors\":{2},\"results\":[{3}]}}",
            registered, billed, errors, string.Join(",", results.ToArray())));
    }

    private bool ClearStudent(int id)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = @"UPDATE acad_registration
                    SET regstatus='CLEARED', examClearance='CLEARED',
                        examClearanceDate=NOW(), clearedBy=@user
                    WHERE ID=@id AND regstatus IN ('REGISTERED','LATE REGISTERED')";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id",   id);
                    cmd.Parameters.AddWithValue("@user", GetCurrentUser());
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch { return false; }
    }

    private bool ForceStatus(int id, string newStatus)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand("UPDATE acad_registration SET regstatus=@s WHERE ID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@s",  newStatus);
                    cmd.Parameters.AddWithValue("@id", id);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch { return false; }
    }

    private bool BatchUndoReg(int id)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE acad_registration SET regstatus='UNREGISTERED', registeredBy=NULL WHERE ID=@id AND regstatus IN ('REGISTERED','LATE REGISTERED')", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch { return false; }
    }

    private bool BatchUndoClear(int id)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE acad_registration SET regstatus='REGISTERED', examClearance='UNCLEARED', examClearanceDate=NULL, clearedBy=NULL WHERE ID=@id AND examClearance='CLEARED'", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch { return false; }
    }

    private bool BatchReactivate(int id)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE acad_registration SET regstatus='UNREGISTERED', registeredBy=NULL, examClearance='UNCLEARED' WHERE ID=@id AND regstatus IN ('DISCONTINUED','HALTED','DEAD YEAR')", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch { return false; }
    }

    private bool BatchDeleteReg(int id)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                // Fetch details for audit log
                string regno = "", acadYear = "";
                int semester = 0;
                using (var cmd = new MySqlCommand("SELECT regno, acad_year, semester FROM acad_registration WHERE ID=@id LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            regno    = rdr["regno"].ToString();
                            acadYear = rdr["acad_year"].ToString();
                            semester = Convert.ToInt32(rdr["semester"]);
                        }
                    }
                }
                if (string.IsNullOrEmpty(regno)) return false;

                using (var cmd = new MySqlCommand("DELETE FROM acad_registration WHERE ID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    if (ok)
                    {
                        using (var logCmd = new MySqlCommand(
                            "INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date) VALUES (@usr, 'Batch Delete Registration', @par, 'Deleted registration record', NOW())", conn))
                        {
                            logCmd.Parameters.AddWithValue("@usr", GetCurrentUser());
                            logCmd.Parameters.AddWithValue("@par", string.Format("{0} | {1} Sem {2}", regno, acadYear, semester));
                            logCmd.ExecuteNonQuery();
                        }
                    }
                    return ok;
                }
            }
        }
        catch { return false; }
    }

    // ===================================================================
    // UTILITIES
    // ===================================================================

    private void ShowToast(bool success, string message)
    {
        string js = string.Format("showToast({0},'{1}');",
            success ? "true" : "false",
            message.Replace("'", "\\'").Replace("\r", "").Replace("\n", ""));
        ScriptManager.RegisterStartupScript(this, GetType(), "toast_" + Guid.NewGuid().ToString("N"), js, true);
    }

    private int GetLinkButtonID(object sender)
    {
        var btn = sender as LinkButton;
        if (btn == null) return 0;
        int id;
        return int.TryParse(btn.CommandArgument, out id) ? id : 0;
    }

    private int SafeInt(string val, int def = 0)
    {
        int r; return int.TryParse(val, out r) ? r : def;
    }
    private int SafeInt(object val, int def = 0)
    {
        if (val == null || val == DBNull.Value) return def;
        int r; return int.TryParse(val.ToString(), out r) ? r : def;
    }
    private string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        string s = val.ToString().Trim();
        return string.IsNullOrEmpty(s) ? "0" : s;
    }

    private string FormatCount(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        long n;
        if (long.TryParse(val.ToString(), out n)) return n.ToString("N0");
        return val.ToString();
    }

    /// <summary>Escape a value for safe inclusion inside a JS single-quoted string literal.</summary>
    protected string JsEncode(object val)
    {
        string s = (val == null || val == DBNull.Value) ? "" : val.ToString();
        return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
    }
}
