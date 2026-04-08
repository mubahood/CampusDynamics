using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_HREmployees : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─── Query-string helpers ──────────────────────────────────────────────────
    private int    QsPage    { get { int v; return int.TryParse(Request.QueryString["page"] ?? "1", out v) && v > 0 ? v : 1; } }
    private string QsSearch  { get { return (Request.QueryString["q"]       ?? "").Trim(); } }
    private string QsStatus  { get { return (Request.QueryString["status"]  ?? "").Trim().ToUpper(); } }
    private string QsType    { get { return (Request.QueryString["type"]    ?? "").Trim(); } }
    private string QsDept    { get { return (Request.QueryString["dept"]    ?? "").Trim(); } }
    private string QsStation { get { return (Request.QueryString["station"] ?? "").Trim(); } }
    private int    QsSize
    {
        get
        {
            int v;
            if (int.TryParse(Request.QueryString["sz"] ?? "50", out v) && v > 0) return v;
            return 50;
        }
    }

    // ─── One-time schema migration ─────────────────────────────────────────────
    private static bool _schemaChecked = false;
    private void EnsureDbSchema()
    {
        if (_schemaChecked) return;
        try
        {
            DataTable dt1 = ExecuteQuery("SHOW COLUMNS FROM hrm_employee LIKE 'nin'");
            if (dt1.Rows.Count == 0)
                ExecuteNonQuery("ALTER TABLE hrm_employee ADD COLUMN nin VARCHAR(50) DEFAULT NULL");
        }
        catch { }
        try
        {
            DataTable dt2 = ExecuteQuery("SHOW COLUMNS FROM hrm_employee LIKE 'supervisorID'");
            if (dt2.Rows.Count == 0)
                ExecuteNonQuery("ALTER TABLE hrm_employee ADD COLUMN supervisorID INT DEFAULT NULL");
        }
        catch { }
        _schemaChecked = true;
    }

    // ─── Page lifecycle ────────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureDbSchema();

        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        LoadFormDropdowns();

        if (!IsPostBack)
        {
            LoadFilterDropdowns();
            BindGrid();
            LoadStats();
            ShowFlashMessage();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  AJAX ROUTER
    // ═══════════════════════════════════════════════════════════════════════════
    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        try
        {
            switch (action)
            {
                case "search_emp":   AjaxSearchEmployee(); break;
                case "get_emp":      AjaxGetEmployee();    break;
                case "get_profile":  AjaxGetProfile();     break;
                default:
                    Response.Write("{\"error\":\"Unknown action\"}");
                    break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + EscapeJson(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ─── AJAX: Employee Search (for supervisor autocomplete) ───────────────────
    private void AjaxSearchEmployee()
    {
        string q = (Request.QueryString["q"] ?? "").Trim();
        if (q.Length < 1) { Response.Write("{\"results\":[]}"); return; }

        DataTable dt = ExecuteQuery(
            @"SELECT e.empID, e.emp_name, e.EMP_CODE,
                     IFNULL(j.jobname, 'Staff') AS emp_position
              FROM hrm_employee e
              LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
                  AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
              LEFT JOIN hrm_jobs j ON j.ID = c.jobID
              WHERE e.emp_name LIKE @q OR e.EMP_CODE LIKE @q
              ORDER BY e.emp_name LIMIT 15",
            new MySqlParameter("@q", "%" + q + "%"));

        var list = new List<string>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(string.Format("{{\"empID\":\"{0}\",\"emp_name\":\"{1}\",\"EMP_CODE\":\"{2}\",\"emp_position\":\"{3}\"}}",
                EscapeJson(row["empID"]), EscapeJson(row["emp_name"]),
                EscapeJson(row["EMP_CODE"]), EscapeJson(row["emp_position"])));
        }
        Response.Write("{\"results\":[" + string.Join(",", list) + "]}");
    }

    // ─── AJAX: Get Employee for Edit ───────────────────────────────────────────
    private void AjaxGetEmployee()
    {
        int id;
        if (!int.TryParse(Request.QueryString["id"], out id))
        { Response.Write("{\"error\":\"Invalid ID\"}"); return; }

        DataTable dt = ExecuteQuery(
            @"SELECT e.empID, e.EMP_CODE, e.emp_name, e.emp_email, e.emp_phone,
                     e.emp_birthdate, e.gender, e.emp_qualifications, e.emp_nationality,
                     e.EmpType, e.marital_status, e.address, e.current_residence,
                     e.religion, e.tribe, e.tin, e.nssf_no, e.max_education,
                     e.bankID, e.bankAccount, e.spouse_name, e.no_children,
                     e.father_name, e.mother_name, e.contact_person, e.relation,
                     e.phone_contacts, e.referee_1, e.referee_2,
                     e.medical_background, e.schooling_info, e.employment_info,
                     e.usernames, e.Entry_Year, e.Entry_Satation,
                     IFNULL(e.nin,'') AS nin,
                     IFNULL(e.supervisorID,0) AS supervisorID,
                     IFNULL(sup.emp_name,'') AS supervisor_name,
                     IFNULL(sup.EMP_CODE,'') AS supervisor_code
              FROM hrm_employee e
              LEFT JOIN hrm_employee sup ON sup.empID = e.supervisorID
              WHERE e.empID = @id",
            new MySqlParameter("@id", id));

        if (dt.Rows.Count == 0) { Response.Write("{\"error\":\"Not found\"}"); return; }

        DataRow r = dt.Rows[0];
        StringBuilder sb = new StringBuilder("{");
        bool first = true;
        foreach (DataColumn col in dt.Columns)
        {
            if (!first) sb.Append(",");
            first = false;
            string val = "";
            if (r[col] != null && r[col] != DBNull.Value)
            {
                if (col.DataType == typeof(DateTime))
                    val = ((DateTime)r[col]).ToString("yyyy-MM-dd");
                else
                    val = r[col].ToString();
            }
            sb.AppendFormat("\"{0}\":\"{1}\"", col.ColumnName, EscapeJson(val));
        }
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    // ─── AJAX: Get Employee Profile ────────────────────────────────────────────
    private void AjaxGetProfile()
    {
        int id;
        if (!int.TryParse(Request.QueryString["id"], out id))
        { Response.Write("{\"error\":\"Invalid ID\"}"); return; }

        DataTable dtEmp = ExecuteQuery(@"
            SELECT e.*, d.dept_name, st.station_name,
                   c.contractStatus, c.contractStart, c.contractEnd,
                   ps.scale_name, IFNULL(ps.basicpay, c.fixedamount) AS basicpay, j.jobname,
                   IFNULL(sup.emp_name,'') AS supervisor_name
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
                AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            LEFT JOIN hrm_employee sup ON sup.empID = e.supervisorID
            WHERE e.empID = @id",
            new MySqlParameter("@id", id));

        if (dtEmp.Rows.Count == 0) { Response.Write("{\"error\":\"Not found\"}"); return; }

        DataRow emp = dtEmp.Rows[0];
        string empCode = SafeVal(emp["EMP_CODE"]);

        object bpVal = emp["basicpay"];
        string payStr = (bpVal != null && bpVal != DBNull.Value)
            ? "UGX " + Convert.ToDecimal(bpVal).ToString("N0") : "N/A";

        StringBuilder sb = new StringBuilder("{");
        sb.AppendFormat("\"name\":\"{0}\",", EscapeJson(emp["emp_name"]));
        sb.AppendFormat("\"code\":\"{0}\",", EscapeJson(empCode));
        sb.AppendFormat("\"type\":\"{0}\",", EscapeJson(emp["EmpType"]));
        sb.AppendFormat("\"photo\":\"{0}\",", EscapeJson(GetPhotoUrl(empCode)));
        sb.AppendFormat("\"dept\":\"{0}\",", EscapeJson(emp["dept_name"]));
        sb.AppendFormat("\"station\":\"{0}\",", EscapeJson(emp["station_name"]));
        sb.AppendFormat("\"pay\":\"{0}\",", EscapeJson(payStr));
        sb.AppendFormat("\"statusBadge\":\"{0}\",", EscapeJson(GetStatusBadge(emp["contractStatus"])));
        sb.AppendFormat("\"bioHtml\":\"{0}\",", EscapeJson(BuildBioDataHtml(emp)));
        sb.AppendFormat("\"contractsHtml\":\"{0}\",", EscapeJson(BuildContractsHtml(id)));
        sb.AppendFormat("\"qualificationsHtml\":\"{0}\",", EscapeJson(BuildQualificationsHtml(empCode)));
        sb.AppendFormat("\"leaveHtml\":\"{0}\",", EscapeJson(BuildLeaveHtml(id)));
        sb.AppendFormat("\"payrollHtml\":\"{0}\",", EscapeJson(BuildPayrollHtml(id)));
        sb.AppendFormat("\"emergencyHtml\":\"{0}\"", EscapeJson(BuildEmergencyHtml(emp)));
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  FILTER / FORM DROPDOWNS
    // ═══════════════════════════════════════════════════════════════════════════
    private void LoadFilterDropdowns()
    {
        // Departments
        DataTable dtDepts = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlFilterDept.Items.Clear();
        ddlFilterDept.Items.Add(new ListItem("All Departments", ""));
        foreach (DataRow r in dtDepts.Rows)
            ddlFilterDept.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));
        SelectByValue(ddlFilterDept, QsDept);

        // Stations
        DataTable dtStations = ExecuteQuery("SELECT ID, station_name FROM hrm_stations ORDER BY station_name");
        ddlFilterStation.Items.Clear();
        ddlFilterStation.Items.Add(new ListItem("All Stations", ""));
        foreach (DataRow r in dtStations.Rows)
            ddlFilterStation.Items.Add(new ListItem(r["station_name"].ToString(), r["ID"].ToString()));
        SelectByValue(ddlFilterStation, QsStation);

        // Type - static items in ASPX, just pre-select
        SelectByValue(ddlFilterType, QsType);

        // Status - static items in ASPX, just pre-select
        SelectByValue(ddlFilterStatus, QsStatus);

        // Page size
        SelectByValue(ddlPageSize, QsSize.ToString());

        // Search box
        txtSearch.Text = QsSearch;
    }

    private void LoadFormDropdowns()
    {
        // Stations
        DataTable dtStations = ExecuteQuery("SELECT ID, station_name FROM hrm_stations ORDER BY station_name");
        ddlStation.Items.Clear();
        ddlStation.Items.Add(new ListItem("-- Select Station --", ""));
        foreach (DataRow r in dtStations.Rows)
            ddlStation.Items.Add(new ListItem(r["station_name"].ToString(), r["ID"].ToString()));

        // Banks
        DataTable dtBanks = ExecuteQuery("SELECT bank_id, bank_name FROM banks ORDER BY bank_name");
        ddlBank.Items.Clear();
        ddlBank.Items.Add(new ListItem("-- Select Bank --", ""));
        foreach (DataRow r in dtBanks.Rows)
            ddlBank.Items.Add(new ListItem(r["bank_name"].ToString(), r["bank_id"].ToString()));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  STATS
    // ═══════════════════════════════════════════════════════════════════════════
    private void LoadStats()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN e.EmpType = 'Academic' THEN 1 ELSE 0 END) AS academic,
                SUM(CASE WHEN e.EmpType = 'Administrative' THEN 1 ELSE 0 END) AS admin,
                SUM(CASE WHEN c.contractStatus = 'VALID' THEN 1 ELSE 0 END) AS active_ct,
                SUM(CASE WHEN c.contractStatus IS NULL OR c.contractStatus != 'VALID' THEN 1 ELSE 0 END) AS inactive
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
                AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)");

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litStatTotal.Text    = Convert.ToInt32(r["total"]).ToString();
            litStatAcademic.Text = Convert.ToInt32(r["academic"]).ToString();
            litStatAdmin.Text    = Convert.ToInt32(r["admin"]).ToString();
            litStatActive.Text   = Convert.ToInt32(r["active_ct"]).ToString();
            litStatInactive.Text = Convert.ToInt32(r["inactive"]).ToString();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  GRID BINDING (GET-based pagination)
    // ═══════════════════════════════════════════════════════════════════════════
    private void BindGrid()
    {
        int pageSize = QsSize;
        int page = QsPage;

        // ── Build WHERE clause ──
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(QsSearch))
        {
            where.Append(" AND (e.emp_name LIKE @q OR e.EMP_CODE LIKE @q OR e.emp_email LIKE @q OR e.emp_phone LIKE @q OR e.usernames LIKE @q) ");
            parms.Add(new MySqlParameter("@q", "%" + QsSearch + "%"));
        }
        if (!string.IsNullOrEmpty(QsDept))
        {
            where.Append(" AND c.departmentID = @dept ");
            parms.Add(new MySqlParameter("@dept", QsDept));
        }
        if (!string.IsNullOrEmpty(QsStation))
        {
            where.Append(" AND e.Entry_Satation = @station ");
            parms.Add(new MySqlParameter("@station", QsStation));
        }
        if (!string.IsNullOrEmpty(QsType))
        {
            where.Append(" AND e.EmpType = @etype ");
            parms.Add(new MySqlParameter("@etype", QsType));
        }
        if (!string.IsNullOrEmpty(QsStatus))
        {
            where.Append(" AND c.contractStatus = @cstatus ");
            parms.Add(new MySqlParameter("@cstatus", QsStatus));
        }

        string baseFrom = @"
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
                AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID";

        // ── COUNT ──
        string countSql = "SELECT COUNT(*) " + baseFrom + where.ToString();
        DataTable dtCount = ExecuteQuery(countSql, CloneParams(parms).ToArray());
        int totalRows = Convert.ToInt32(dtCount.Rows[0][0]);
        int totalPages = (int)Math.Ceiling((double)totalRows / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;
        int offset = (page - 1) * pageSize;

        // ── DATA ──
        string dataSql = @"
            SELECT e.empID, e.EMP_CODE, e.emp_name, e.emp_email, e.emp_phone,
                   e.EmpType, e.usernames,
                   IFNULL(d.dept_name,'') AS dept_name,
                   IFNULL(st.station_name,'') AS station_name,
                   IFNULL(j.jobname,'') AS jobname,
                   IFNULL(c.contractStatus,'') AS contractStatus,
                   IFNULL(ps.scale_name,'') AS scale_name,
                   IFNULL(ps.basicpay, c.fixedamount) AS basicpay"
            + baseFrom + where.ToString()
            + " ORDER BY e.emp_name ASC LIMIT @limit OFFSET @offset";

        List<MySqlParameter> dataParms = CloneParams(parms);
        dataParms.Add(new MySqlParameter("@limit", pageSize));
        dataParms.Add(new MySqlParameter("@offset", offset));

        DataTable dt = ExecuteQuery(dataSql, dataParms.ToArray());

        // ── Render rows ──
        StringBuilder html = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            html.Append("<tr><td colspan='10' class='ct-empty-state'>");
            html.Append("<svg xmlns='http://www.w3.org/2000/svg' width='40' height='40' viewBox='0 0 24 24' fill='none' stroke='#ccc' stroke-width='1.5'><circle cx='11' cy='11' r='8'/><line x1='21' y1='21' x2='16.65' y2='16.65'/></svg>");
            html.Append("<div style='margin-top:8px;font-size:13px;color:#999;'>No employees found</div>");
            html.Append("<div style='font-size:11px;color:#bbb;margin-top:2px;'>Try adjusting your search or filters</div>");
            html.Append("</td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow r in dt.Rows)
            {
                rowNum++;
                string empID   = r["empID"].ToString();
                string empCode = SafeVal(r["EMP_CODE"]);
                string empName = SafeVal(r["emp_name"]);
                string email   = SafeVal(r["emp_email"]);
                string phone   = SafeVal(r["emp_phone"]);
                string empType = SafeVal(r["EmpType"]);
                string dept    = SafeVal(r["dept_name"]);
                string station = SafeVal(r["station_name"]);
                string status  = SafeVal(r["contractStatus"]);
                string scale   = SafeVal(r["scale_name"]);

                string photoUrl = GetPhotoUrl(empCode);
                string typeBadge = GetTypeBadge(empType);
                string statusBadge = GetStatusBadge(status);

                html.Append("<tr>");

                // #
                html.AppendFormat("<td class='ct-col-num'>{0}</td>", offset + rowNum);

                // Employee (photo + name + email)
                html.Append("<td class='ct-col-emp'>");
                html.AppendFormat("<div class='emp-cell'><img src='{0}' class='emp-thumb' onerror=\"this.onerror=null;this.src='../staffimages/default.jpg'\" ",
                    HttpUtility.HtmlAttributeEncode(photoUrl));
                html.AppendFormat("data-name='{0}' data-code='{1}' onclick='openLightbox(this.src,this.dataset.name,this.dataset.code)' alt='' />",
                    HttpUtility.HtmlAttributeEncode(empName), HttpUtility.HtmlAttributeEncode(empCode));
                html.AppendFormat("<div class='emp-info'><div class='emp-name'>{0}</div><div class='emp-sub'>{1}</div></div></div></td>",
                    HttpUtility.HtmlEncode(empName), HttpUtility.HtmlEncode(email));

                // Staff Code
                html.AppendFormat("<td><span class='emp-code'>{0}</span></td>", HttpUtility.HtmlEncode(empCode));

                // Phone
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(phone));

                // Type
                html.AppendFormat("<td>{0}</td>", typeBadge);

                // Department
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(dept));

                // Station
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(station));

                // Status
                html.AppendFormat("<td>{0}</td>", statusBadge);

                // Pay
                html.AppendFormat("<td class='ct-col-pay'>{0}{1}</td>",
                    FormatAmount(r["basicpay"]),
                    !string.IsNullOrEmpty(scale)
                        ? string.Format("<div class='emp-scale'>{0}</div>", HttpUtility.HtmlEncode(scale))
                        : "");

                // Actions
                html.AppendFormat("<td class='ct-col-actions'>{0}</td>",
                    GetActionButtonsHtml(empID, empName, SafeVal(r["usernames"]), email));

                html.Append("</tr>");
            }
        }
        litGridBody.Text = html.ToString();

        // ── Pager ──
        litPagerInfo.Text = string.Format("Showing {0}&ndash;{1} of {2}",
            totalRows > 0 ? offset + 1 : 0,
            Math.Min(offset + pageSize, totalRows),
            totalRows);
        litPager.Text = BuildPager(page, totalPages);
    }

    private string BuildPager(int currentPage, int totalPages)
    {
        if (totalPages <= 1) return "";

        StringBuilder sb = new StringBuilder("<div class='ct-pager'>");

        // Build base URL preserving all filters
        string baseUrl = BuildFilterUrl("");

        // First / Prev
        if (currentPage > 1)
        {
            sb.AppendFormat("<a class='ct-pager__item' href='{0}page=1'>&laquo;</a>", baseUrl);
            sb.AppendFormat("<a class='ct-pager__item' href='{0}page={1}'>&lsaquo;</a>", baseUrl, currentPage - 1);
        }
        else
        {
            sb.Append("<span class='ct-pager__item ct-pager__item--disabled'>&laquo;</span>");
            sb.Append("<span class='ct-pager__item ct-pager__item--disabled'>&lsaquo;</span>");
        }

        // Page window ±2
        int start = Math.Max(1, currentPage - 2);
        int end = Math.Min(totalPages, currentPage + 2);

        if (start > 1) sb.Append("<span class='ct-pager__ellipsis'>&hellip;</span>");

        for (int i = start; i <= end; i++)
        {
            if (i == currentPage)
                sb.AppendFormat("<span class='ct-pager__item ct-pager__item--active'>{0}</span>", i);
            else
                sb.AppendFormat("<a class='ct-pager__item' href='{0}page={1}'>{1}</a>", baseUrl, i);
        }

        if (end < totalPages) sb.Append("<span class='ct-pager__ellipsis'>&hellip;</span>");

        // Next / Last
        if (currentPage < totalPages)
        {
            sb.AppendFormat("<a class='ct-pager__item' href='{0}page={1}'>&rsaquo;</a>", baseUrl, currentPage + 1);
            sb.AppendFormat("<a class='ct-pager__item' href='{0}page={1}'>&raquo;</a>", baseUrl, totalPages);
        }
        else
        {
            sb.Append("<span class='ct-pager__item ct-pager__item--disabled'>&rsaquo;</span>");
            sb.Append("<span class='ct-pager__item ct-pager__item--disabled'>&raquo;</span>");
        }

        sb.Append("</div>");
        return sb.ToString();
    }

    private string BuildFilterUrl(string extra)
    {
        var parts = new List<string>();
        if (!string.IsNullOrEmpty(QsSearch))  parts.Add("q=" + HttpUtility.UrlEncode(QsSearch));
        if (!string.IsNullOrEmpty(QsStatus))  parts.Add("status=" + HttpUtility.UrlEncode(QsStatus));
        if (!string.IsNullOrEmpty(QsType))    parts.Add("type=" + HttpUtility.UrlEncode(QsType));
        if (!string.IsNullOrEmpty(QsDept))    parts.Add("dept=" + HttpUtility.UrlEncode(QsDept));
        if (!string.IsNullOrEmpty(QsStation)) parts.Add("station=" + HttpUtility.UrlEncode(QsStation));
        if (QsSize != 50)                     parts.Add("sz=" + QsSize);
        if (!string.IsNullOrEmpty(extra))     parts.Add(extra);
        string qs = string.Join("&", parts);
        return "HREmployees.aspx?" + (qs.Length > 0 ? qs + "&" : "");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  ADD EMPLOYEE
    // ═══════════════════════════════════════════════════════════════════════════
    protected void btnAddEmployee_Click(object sender, EventArgs e)
    {
        string name  = (Request.Form[txtEmpName.UniqueID] ?? "").Trim();
        string email = (Request.Form[txtEmpEmail.UniqueID] ?? "").Trim();
        string phone = (Request.Form[txtEmpPhone.UniqueID] ?? "").Trim();

        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone))
        {
            ShowResult("empFormResult", "empFormModal", "Name, Email and Phone are required.", false);
            return;
        }

        string empCode = GenerateEmpCode();

        DateTime dob;
        bool hasDOB = DateTime.TryParse(Request.Form[txtEmpDOB.UniqueID], out dob);
        int bankId = SafeInt(Request.Form[ddlBank.UniqueID]);
        int nChildren = SafeInt(Request.Form[txtChildren.UniqueID]);
        int entryYear = SafeInt(Request.Form[txtEntryYear.UniqueID]);
        if (entryYear == 0) entryYear = DateTime.Now.Year;
        int supervisorId = SafeInt(Request.Form[hfSupervisorID.UniqueID]);

        string sql = @"INSERT INTO hrm_employee
            (EMP_CODE, emp_name, emp_email, emp_phone, emp_birthdate, gender,
             emp_qualifications, max_education, emp_nationality, EmpType,
             marital_status, address, current_residence, religion, tribe,
             tin, nssf_no, nin, bankID, bankAccount,
             spouse_name, no_children, father_name, mother_name,
             contact_person, relation, phone_contacts,
             referee_1, referee_2, medical_background, schooling_info, employment_info,
             Entry_Year, Entry_Satation, supervisorID)
            VALUES
            (@code, @name, @email, @phone, @dob, @gender,
             @qual, @maxEdu, @nat, @empType,
             @marital, @addr, @residence, @religion, @tribe,
             @tin, @nssf, @nin, @bankID, @bankAcct,
             @spouse, @nChildren, @father, @mother,
             @contactPerson, @relation, @contactPhone,
             @ref1, @ref2, @medical, @schooling, @employment,
             @year, @station, @supervisorID)";

        ExecuteNonQuery(sql,
            new MySqlParameter("@code", empCode),
            new MySqlParameter("@name", name),
            new MySqlParameter("@email", email),
            new MySqlParameter("@phone", phone),
            new MySqlParameter("@dob", hasDOB ? (object)dob : DBNull.Value),
            new MySqlParameter("@gender", Request.Form[ddlGender.UniqueID] ?? "Male"),
            new MySqlParameter("@qual", (Request.Form[txtQualifications.UniqueID] ?? "").Trim()),
            new MySqlParameter("@maxEdu", Request.Form[ddlEducation.UniqueID] ?? "NA"),
            new MySqlParameter("@nat", Request.Form[ddlNationality.UniqueID] ?? "UGANDAN"),
            new MySqlParameter("@empType", Request.Form[ddlEmpType.UniqueID] ?? "Administrative"),
            new MySqlParameter("@marital", Request.Form[ddlMarital.UniqueID] ?? "SINGLE"),
            new MySqlParameter("@addr", (Request.Form[txtAddress.UniqueID] ?? "").Trim()),
            new MySqlParameter("@residence", (Request.Form[txtResidence.UniqueID] ?? "UGANDA").Trim()),
            new MySqlParameter("@religion", (Request.Form[txtReligion.UniqueID] ?? "").Trim()),
            new MySqlParameter("@tribe", (Request.Form[txtTribe.UniqueID] ?? "").Trim()),
            new MySqlParameter("@tin", (Request.Form[txtTIN.UniqueID] ?? "").Trim()),
            new MySqlParameter("@nssf", (Request.Form[txtNSSF.UniqueID] ?? "").Trim()),
            new MySqlParameter("@nin", (Request.Form[txtNIN.UniqueID] ?? "").Trim()),
            new MySqlParameter("@bankID", bankId),
            new MySqlParameter("@bankAcct", (Request.Form[txtBankAccount.UniqueID] ?? "").Trim()),
            new MySqlParameter("@spouse", (Request.Form[txtSpouse.UniqueID] ?? "").Trim()),
            new MySqlParameter("@nChildren", nChildren),
            new MySqlParameter("@father", (Request.Form[txtFather.UniqueID] ?? "").Trim()),
            new MySqlParameter("@mother", (Request.Form[txtMother.UniqueID] ?? "").Trim()),
            new MySqlParameter("@contactPerson", (Request.Form[txtContactPerson.UniqueID] ?? "").Trim()),
            new MySqlParameter("@relation", (Request.Form[txtRelation.UniqueID] ?? "").Trim()),
            new MySqlParameter("@contactPhone", (Request.Form[txtContactPhone.UniqueID] ?? "").Trim()),
            new MySqlParameter("@ref1", (Request.Form[txtReferee1.UniqueID] ?? "-").Trim()),
            new MySqlParameter("@ref2", (Request.Form[txtReferee2.UniqueID] ?? "-").Trim()),
            new MySqlParameter("@medical", (Request.Form[txtMedical.UniqueID] ?? "").Trim()),
            new MySqlParameter("@schooling", (Request.Form[txtSchooling.UniqueID] ?? "").Trim()),
            new MySqlParameter("@employment", (Request.Form[txtEmploymentHist.UniqueID] ?? "").Trim()),
            new MySqlParameter("@year", entryYear),
            new MySqlParameter("@station", Request.Form[ddlStation.UniqueID] ?? ""),
            new MySqlParameter("@supervisorID", supervisorId > 0 ? (object)supervisorId : DBNull.Value)
        );

        RedirectWithFlash(string.Format("Employee {0} ({1}) added successfully.", name, empCode), true);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  EDIT EMPLOYEE
    // ═══════════════════════════════════════════════════════════════════════════
    protected void btnEditEmployee_Click(object sender, EventArgs e)
    {
        int empID = SafeInt(Request.Form[hdnEditEmpID.UniqueID]);
        if (empID <= 0) return;

        string name  = (Request.Form[txtEmpName.UniqueID] ?? "").Trim();
        string email = (Request.Form[txtEmpEmail.UniqueID] ?? "").Trim();
        string phone = (Request.Form[txtEmpPhone.UniqueID] ?? "").Trim();

        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone))
        {
            ShowResult("empFormResult", "empFormModal", "Name, Email and Phone are required.", false);
            return;
        }

        DateTime dob;
        bool hasDOB = DateTime.TryParse(Request.Form[txtEmpDOB.UniqueID], out dob);
        int bankId = SafeInt(Request.Form[ddlBank.UniqueID]);
        int nChildren = SafeInt(Request.Form[txtChildren.UniqueID]);
        int entryYear = SafeInt(Request.Form[txtEntryYear.UniqueID]);
        if (entryYear == 0) entryYear = DateTime.Now.Year;
        int supervisorId = SafeInt(Request.Form[hfSupervisorID.UniqueID]);

        string sql = @"UPDATE hrm_employee SET
            emp_name = @name, emp_email = @email, emp_phone = @phone,
            emp_birthdate = @dob, gender = @gender,
            emp_qualifications = @qual, max_education = @maxEdu,
            emp_nationality = @nat, EmpType = @empType,
            marital_status = @marital, address = @addr, current_residence = @residence,
            religion = @religion, tribe = @tribe,
            tin = @tin, nssf_no = @nssf, nin = @nin,
            bankID = @bankID, bankAccount = @bankAcct,
            spouse_name = @spouse, no_children = @nChildren,
            father_name = @father, mother_name = @mother,
            contact_person = @contactPerson, relation = @relation,
            phone_contacts = @contactPhone,
            referee_1 = @ref1, referee_2 = @ref2,
            medical_background = @medical, schooling_info = @schooling,
            employment_info = @employment,
            Entry_Year = @year, Entry_Satation = @station,
            supervisorID = @supervisorID
            WHERE empID = @empID";

        ExecuteNonQuery(sql,
            new MySqlParameter("@name", name),
            new MySqlParameter("@email", email),
            new MySqlParameter("@phone", phone),
            new MySqlParameter("@dob", hasDOB ? (object)dob : DBNull.Value),
            new MySqlParameter("@gender", Request.Form[ddlGender.UniqueID] ?? "Male"),
            new MySqlParameter("@qual", (Request.Form[txtQualifications.UniqueID] ?? "").Trim()),
            new MySqlParameter("@maxEdu", Request.Form[ddlEducation.UniqueID] ?? "NA"),
            new MySqlParameter("@nat", Request.Form[ddlNationality.UniqueID] ?? "UGANDAN"),
            new MySqlParameter("@empType", Request.Form[ddlEmpType.UniqueID] ?? "Administrative"),
            new MySqlParameter("@marital", Request.Form[ddlMarital.UniqueID] ?? "SINGLE"),
            new MySqlParameter("@addr", (Request.Form[txtAddress.UniqueID] ?? "").Trim()),
            new MySqlParameter("@residence", (Request.Form[txtResidence.UniqueID] ?? "UGANDA").Trim()),
            new MySqlParameter("@religion", (Request.Form[txtReligion.UniqueID] ?? "").Trim()),
            new MySqlParameter("@tribe", (Request.Form[txtTribe.UniqueID] ?? "").Trim()),
            new MySqlParameter("@tin", (Request.Form[txtTIN.UniqueID] ?? "").Trim()),
            new MySqlParameter("@nssf", (Request.Form[txtNSSF.UniqueID] ?? "").Trim()),
            new MySqlParameter("@nin", (Request.Form[txtNIN.UniqueID] ?? "").Trim()),
            new MySqlParameter("@bankID", bankId),
            new MySqlParameter("@bankAcct", (Request.Form[txtBankAccount.UniqueID] ?? "").Trim()),
            new MySqlParameter("@spouse", (Request.Form[txtSpouse.UniqueID] ?? "").Trim()),
            new MySqlParameter("@nChildren", nChildren),
            new MySqlParameter("@father", (Request.Form[txtFather.UniqueID] ?? "").Trim()),
            new MySqlParameter("@mother", (Request.Form[txtMother.UniqueID] ?? "").Trim()),
            new MySqlParameter("@contactPerson", (Request.Form[txtContactPerson.UniqueID] ?? "").Trim()),
            new MySqlParameter("@relation", (Request.Form[txtRelation.UniqueID] ?? "").Trim()),
            new MySqlParameter("@contactPhone", (Request.Form[txtContactPhone.UniqueID] ?? "").Trim()),
            new MySqlParameter("@ref1", (Request.Form[txtReferee1.UniqueID] ?? "-").Trim()),
            new MySqlParameter("@ref2", (Request.Form[txtReferee2.UniqueID] ?? "-").Trim()),
            new MySqlParameter("@medical", (Request.Form[txtMedical.UniqueID] ?? "").Trim()),
            new MySqlParameter("@schooling", (Request.Form[txtSchooling.UniqueID] ?? "").Trim()),
            new MySqlParameter("@employment", (Request.Form[txtEmploymentHist.UniqueID] ?? "").Trim()),
            new MySqlParameter("@year", entryYear),
            new MySqlParameter("@station", Request.Form[ddlStation.UniqueID] ?? ""),
            new MySqlParameter("@supervisorID", supervisorId > 0 ? (object)supervisorId : DBNull.Value),
            new MySqlParameter("@empID", empID)
        );

        RedirectWithFlash(string.Format("Employee {0} updated successfully.", name), true);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  DELETE EMPLOYEE
    // ═══════════════════════════════════════════════════════════════════════════
    protected void btnDeleteEmployee_Click(object sender, EventArgs e)
    {
        int empID = SafeInt(Request.Form[hdnDeleteEmpID.UniqueID]);
        if (empID <= 0) return;
        ExecuteNonQuery("DELETE FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));
        RedirectWithFlash("Employee deleted successfully.", true);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  CHANGE PASSWORD
    // ═══════════════════════════════════════════════════════════════════════════
    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        int empID;
        if (!int.TryParse(Request.Form[hdnPwdEmpID.UniqueID], out empID) || empID <= 0) return;

        string newPwd     = (Request.Form[txtNewPassword.UniqueID] ?? "").Trim();
        string confirmPwd = (Request.Form[txtConfirmPassword.UniqueID] ?? "").Trim();

        if (string.IsNullOrEmpty(newPwd) || newPwd != confirmPwd)
        {
            ShowResult("pwdResult", "changePwdModal", "Passwords do not match.", false);
            return;
        }

        DataTable dt = ExecuteQuery("SELECT usernames, emp_email FROM hrm_employee WHERE empID = @id",
            new MySqlParameter("@id", empID));
        if (dt.Rows.Count == 0) return;

        string username = dt.Rows[0]["usernames"].ToString().Trim();
        if (string.IsNullOrEmpty(username) || username == "-")
            username = dt.Rows[0]["emp_email"].ToString().Trim();
        if (username == "-") username = "";

        if (string.IsNullOrEmpty(username))
        {
            ShowResult("pwdResult", "changePwdModal", "This employee has no username or email assigned.", false);
            return;
        }

        try
        {
            MembershipUser user = Membership.GetUser(username);
            if (user == null)
            {
                string nameByEmail = Membership.GetUserNameByEmail(username);
                if (!string.IsNullOrEmpty(nameByEmail))
                    user = Membership.GetUser(nameByEmail);
            }

            if (user == null)
            {
                ShowResult("pwdResult", "changePwdModal",
                    string.Format("No membership account found for '{0}'.", username), false);
                return;
            }

            if (user.IsLockedOut) user.UnlockUser();

            string tempPwd = user.ResetPassword();
            user.ChangePassword(tempPwd, newPwd);

            RedirectWithFlash(string.Format("Password changed successfully for '{0}'.", user.UserName), true);
        }
        catch (Exception ex)
        {
            ShowResult("pwdResult", "changePwdModal", ex.Message, false);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  PROFILE HTML BUILDERS
    // ═══════════════════════════════════════════════════════════════════════════
    private string BuildBioDataHtml(DataRow emp)
    {
        StringBuilder sb = new StringBuilder();

        sb.Append("<div class='ep-section-title'>Personal Details</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Full Name", emp["emp_name"]);
        AddBioItem(sb, "Staff Code", emp["EMP_CODE"]);
        AddBioItem(sb, "Date of Birth", emp["emp_birthdate"] != DBNull.Value ? Convert.ToDateTime(emp["emp_birthdate"]).ToString("dd MMM yyyy") : "");
        AddBioItem(sb, "Gender", emp["gender"]);
        AddBioItem(sb, "Nationality", emp["emp_nationality"]);
        AddBioItem(sb, "Religion", emp["religion"]);
        AddBioItem(sb, "Tribe", emp["tribe"]);
        AddBioItem(sb, "Marital Status", emp["marital_status"]);
        AddBioItem(sb, "NIN", SafeColVal(emp, "nin"));
        AddBioItem(sb, "Current Residence", emp["current_residence"]);
        AddBioItem(sb, "Address", emp["address"]);
        AddBioItem(sb, "Email", emp["emp_email"]);
        AddBioItem(sb, "Phone", emp["emp_phone"]);
        sb.Append("</div>");

        sb.Append("<div class='ep-section-title'>Employment Details</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Employee Type", emp["EmpType"]);
        AddBioItem(sb, "Education Level", emp["max_education"]);
        AddBioItem(sb, "Qualifications", emp["emp_qualifications"]);
        AddBioItem(sb, "Entry Year", emp["Entry_Year"]);
        AddBioItem(sb, "Station", emp["station_name"]);
        AddBioItem(sb, "Job Title", emp["jobname"]);
        AddBioItem(sb, "Supervisor", SafeColVal(emp, "supervisor_name"));
        AddBioItem(sb, "Username", emp["usernames"]);
        sb.Append("</div>");

        string bankName = ResolveBankName(emp["bankID"]);
        sb.Append("<div class='ep-section-title'>Financial Details</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Bank", bankName);
        AddBioItem(sb, "Bank Account", emp["bankAccount"]);
        AddBioItem(sb, "TIN", emp["tin"]);
        AddBioItem(sb, "NSSF No", emp["nssf_no"]);
        AddBioItem(sb, "Pay Scale", emp["scale_name"]);
        AddBioItem(sb, "Basic Pay", emp["basicpay"] != DBNull.Value ? Convert.ToDecimal(emp["basicpay"]).ToString("N0") : "");
        sb.Append("</div>");

        sb.Append("<div class='ep-section-title'>Family</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Spouse Name", emp["spouse_name"]);
        AddBioItem(sb, "No. of Children", emp["no_children"]);
        AddBioItem(sb, "Father's Name", emp["father_name"]);
        AddBioItem(sb, "Mother's Name", emp["mother_name"]);
        sb.Append("</div>");

        // Additional memo fields
        string schooling = SafeVal(emp["schooling_info"]);
        string employment = SafeVal(emp["employment_info"]);
        string medical = SafeVal(emp["medical_background"]);
        if (!string.IsNullOrEmpty(schooling) || !string.IsNullOrEmpty(employment) || !string.IsNullOrEmpty(medical))
        {
            sb.Append("<div class='ep-section-title'>Additional Information</div>");
            sb.Append("<div style='padding:8px 12px;'>");
            if (!string.IsNullOrEmpty(schooling))
            {
                sb.Append("<div style='margin-bottom:10px;'><div class='ep-bio-label'>Academic / Prof. Training</div>");
                sb.AppendFormat("<div style='font-size:12px;color:#333;white-space:pre-wrap;'>{0}</div></div>", HttpUtility.HtmlEncode(schooling));
            }
            if (!string.IsNullOrEmpty(employment))
            {
                sb.Append("<div style='margin-bottom:10px;'><div class='ep-bio-label'>Employment History</div>");
                sb.AppendFormat("<div style='font-size:12px;color:#333;white-space:pre-wrap;'>{0}</div></div>", HttpUtility.HtmlEncode(employment));
            }
            if (!string.IsNullOrEmpty(medical))
            {
                sb.Append("<div style='margin-bottom:10px;'><div class='ep-bio-label'>Medical Background</div>");
                sb.AppendFormat("<div style='font-size:12px;color:#333;white-space:pre-wrap;'>{0}</div></div>", HttpUtility.HtmlEncode(medical));
            }
            sb.Append("</div>");
        }

        return sb.ToString();
    }

    private string BuildContractsHtml(int empID)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT c.ID, c.contractStart, c.contractEnd, c.contractStatus, c.comments,
                   c.fixedamount, j.jobname, d.dept_name, ps.scale_name, ps.basicpay
            FROM hrm_emp_contracts c
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            WHERE c.empID = @id ORDER BY c.contractStart DESC",
            new MySqlParameter("@id", empID));

        if (dt.Rows.Count == 0)
            return "<div class='ep-empty'>No contracts found.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='ep-tbl-scroll'><table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Start</th><th>End</th><th>Job</th><th>Department</th><th>Scale</th><th>Basic Pay</th><th>Status</th>");
        sb.Append("</tr></thead><tbody>");
        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["contractStart"]));
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["contractEnd"]));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["jobname"])));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["dept_name"])));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["scale_name"])));
            sb.AppendFormat("<td class='text-right'>{0}</td>",
                FormatAmount(r["basicpay"] != DBNull.Value ? r["basicpay"] : r["fixedamount"]));
            sb.AppendFormat("<td>{0}</td>", GetStatusBadge(r["contractStatus"]));
            sb.Append("</tr>");
        }
        sb.Append("</tbody></table></div>");
        return sb.ToString();
    }

    private string BuildQualificationsHtml(string empCode)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT qualif, institution, period_start, period_end, award_class
            FROM hrm_qualifications WHERE empcode = @code ORDER BY period_end DESC",
            new MySqlParameter("@code", empCode));

        if (dt.Rows.Count == 0)
            return "<div class='ep-empty'>No qualifications recorded.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='ep-tbl-scroll'><table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Qualification</th><th>Institution</th><th>From</th><th>To</th><th>Classification</th>");
        sb.Append("</tr></thead><tbody>");
        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            sb.AppendFormat("<td><strong>{0}</strong></td>", HttpUtility.HtmlEncode(SafeVal(r["qualif"])));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["institution"])));
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["period_start"]));
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["period_end"]));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["award_class"])));
            sb.Append("</tr>");
        }
        sb.Append("</tbody></table></div>");
        return sb.ToString();
    }

    private string BuildLeaveHtml(int empID)
    {
        DataTable dtAlloc = ExecuteQuery(@"
            SELECT al.leave_year, al.default_days,
                COALESCE(SUM(lt.no_days),0) AS taken_days
            FROM hrm_annual_leave al
            LEFT JOIN hrm_leave_taken lt ON lt.leaveID = al.ID
            WHERE al.empID = @id
            GROUP BY al.ID, al.leave_year, al.default_days
            ORDER BY al.leave_year DESC",
            new MySqlParameter("@id", empID));

        if (dtAlloc.Rows.Count == 0)
            return "<div class='ep-empty'>No leave records found.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='ep-tbl-scroll'><table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Year</th><th class='text-center'>Allocated</th><th class='text-center'>Taken</th><th class='text-center'>Remaining</th>");
        sb.Append("</tr></thead><tbody>");
        foreach (DataRow r in dtAlloc.Rows)
        {
            int allocated = Convert.ToInt32(r["default_days"]);
            int taken = Convert.ToInt32(r["taken_days"]);
            int remaining = allocated - taken;
            string color = remaining <= 0 ? "color:#dc3545;font-weight:600;" : remaining <= 5 ? "color:#ffc107;font-weight:600;" : "color:#28a745;font-weight:600;";
            sb.Append("<tr>");
            sb.AppendFormat("<td><strong>{0}</strong></td>", r["leave_year"]);
            sb.AppendFormat("<td class='text-center'>{0}</td>", allocated);
            sb.AppendFormat("<td class='text-center'>{0}</td>", taken);
            sb.AppendFormat("<td class='text-center' style='{0}'>{1}</td>", color, remaining);
            sb.Append("</tr>");
        }
        sb.Append("</tbody></table></div>");

        // Recent leave details
        DataTable dtDetails = ExecuteQuery(@"
            SELECT lt.startDate, lt.endDate, lt.no_days, al.leave_year
            FROM hrm_leave_taken lt
            JOIN hrm_annual_leave al ON al.ID = lt.leaveID
            WHERE al.empID = @id
            ORDER BY lt.startDate DESC LIMIT 20",
            new MySqlParameter("@id", empID));

        if (dtDetails.Rows.Count > 0)
        {
            sb.Append("<div style='margin-top:12px;'><strong style='font-size:11px;color:#555;'>Recent Leave Taken</strong></div>");
            sb.Append("<div class='ep-tbl-scroll'><table class='ep-data-table' style='margin-top:6px;'><thead><tr>");
            sb.Append("<th>Start Date</th><th>End Date</th><th class='text-center'>Days</th><th>Year</th>");
            sb.Append("</tr></thead><tbody>");
            foreach (DataRow r in dtDetails.Rows)
            {
                sb.Append("<tr>");
                sb.AppendFormat("<td>{0}</td>", FormatDate(r["startDate"]));
                sb.AppendFormat("<td>{0}</td>", FormatDate(r["endDate"]));
                sb.AppendFormat("<td class='text-center'>{0}</td>", r["no_days"]);
                sb.AppendFormat("<td>{0}</td>", r["leave_year"]);
                sb.Append("</tr>");
            }
            sb.Append("</tbody></table></div>");
        }
        return sb.ToString();
    }

    private string BuildPayrollHtml(int empID)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT p.payroll_title, p.payroll_month, p.payroll_year,
                   pd.basic_pay, pd.paye, pd.nssf, pd.total_allowances, pd.total_deductions,
                   pd.gross_pay, pd.net_pay
            FROM hrm_payroll_details pd
            JOIN hrm_payroll p ON p.ID = pd.payrollID
            WHERE pd.empID = @id
            ORDER BY p.payroll_year DESC, p.payroll_month DESC LIMIT 24",
            new MySqlParameter("@id", empID));

        if (dt.Rows.Count == 0)
            return "<div class='ep-empty'>No payroll records found.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='ep-tbl-scroll'><table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Period</th><th class='text-right'>Basic</th><th class='text-right'>Allowances</th>");
        sb.Append("<th class='text-right'>Gross</th><th class='text-right'>PAYE</th><th class='text-right'>NSSF</th>");
        sb.Append("<th class='text-right'>Deductions</th><th class='text-right'>Net Pay</th>");
        sb.Append("</tr></thead><tbody>");
        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            sb.AppendFormat("<td><strong>{0}/{1}</strong><br/><span style='font-size:9px;color:#888;'>{2}</span></td>",
                r["payroll_month"], r["payroll_year"], HttpUtility.HtmlEncode(SafeVal(r["payroll_title"])));
            sb.AppendFormat("<td class='text-right'>{0}</td>", FormatAmount(r["basic_pay"]));
            sb.AppendFormat("<td class='text-right'>{0}</td>", FormatAmount(r["total_allowances"]));
            sb.AppendFormat("<td class='text-right' style='font-weight:600;'>{0}</td>", FormatAmount(r["gross_pay"]));
            sb.AppendFormat("<td class='text-right' style='color:#dc3545;'>{0}</td>", FormatAmount(r["paye"]));
            sb.AppendFormat("<td class='text-right' style='color:#dc3545;'>{0}</td>", FormatAmount(r["nssf"]));
            sb.AppendFormat("<td class='text-right' style='color:#dc3545;'>{0}</td>", FormatAmount(r["total_deductions"]));
            sb.AppendFormat("<td class='text-right' style='font-weight:700;color:#174DA4;'>{0}</td>", FormatAmount(r["net_pay"]));
            sb.Append("</tr>");
        }
        sb.Append("</tbody></table></div>");
        return sb.ToString();
    }

    private string BuildEmergencyHtml(DataRow emp)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='ep-section-title'>Emergency Contact</div>");
        sb.Append("<div class='ep-bio-grid' style='grid-template-columns:repeat(2,1fr);'>");
        AddBioItem(sb, "Contact Person", emp["contact_person"]);
        AddBioItem(sb, "Relationship", emp["relation"]);
        AddBioItem(sb, "Contact Phone", emp["phone_contacts"]);
        sb.Append("</div>");

        sb.Append("<div class='ep-section-title'>Referees</div>");
        sb.Append("<div class='ep-bio-grid' style='grid-template-columns:repeat(2,1fr);'>");
        AddBioItem(sb, "Referee 1", emp["referee_1"]);
        AddBioItem(sb, "Referee 2", emp["referee_2"]);
        sb.Append("</div>");
        return sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  HELPER METHODS
    // ═══════════════════════════════════════════════════════════════════════════
    private string GenerateEmpCode()
    {
        string yearPrefix = "MRU/" + DateTime.Now.Year.ToString() + "/";
        DataTable dt = ExecuteQuery(
            "SELECT EMP_CODE FROM hrm_employee WHERE EMP_CODE LIKE @prefix ORDER BY empID DESC LIMIT 1",
            new MySqlParameter("@prefix", yearPrefix + "%"));

        int nextNum = 1;
        if (dt.Rows.Count > 0)
        {
            string lastCode = dt.Rows[0]["EMP_CODE"].ToString();
            string numPart = lastCode.Substring(lastCode.LastIndexOf('/') + 1);
            int parsed;
            if (int.TryParse(numPart, out parsed)) nextNum = parsed + 1;
        }
        return yearPrefix + nextNum.ToString("D4");
    }

    protected string GetPhotoUrl(object empCode)
    {
        if (empCode == null || empCode == DBNull.Value) return "../staffimages/default.jpg";
        string code = empCode.ToString().Replace("/", "_");
        return "../staffimages/" + code + ".jpg";
    }

    protected string GetStatusBadge(object status)
    {
        if (status == null || status == DBNull.Value || string.IsNullOrEmpty(status.ToString()))
            return "<span class='hr-badge hr-badge--none'>No Contract</span>";
        string s = status.ToString().ToUpper();
        string css = "hr-badge--none";
        if (s == "VALID")      css = "hr-badge--valid";
        else if (s == "EXPIRED")    css = "hr-badge--expired";
        else if (s == "TERMINATED") css = "hr-badge--terminated";
        else if (s == "RESIGNED")   css = "hr-badge--resigned";
        return string.Format("<span class='hr-badge {0}'>{1}</span>", css, HttpUtility.HtmlEncode(s));
    }

    private string GetTypeBadge(string empType)
    {
        if (string.IsNullOrEmpty(empType)) return "";
        string css = empType.Contains("Acad") ? "hr-badge--academic" : "hr-badge--admin";
        return string.Format("<span class='hr-badge {0}'>{1}</span>", css, HttpUtility.HtmlEncode(empType));
    }

    protected string FormatAmount(object val)
    {
        if (val == null || val == DBNull.Value) return "&mdash;";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d)) return d.ToString("N0");
        return val.ToString();
    }

    private string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "&mdash;";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt)) return dt.ToString("dd MMM yyyy");
        return val.ToString();
    }

    private string SafeVal(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private string SafeColVal(DataRow row, string col)
    {
        if (!row.Table.Columns.Contains(col)) return "";
        object val = row[col];
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private string ResolveBankName(object bankID)
    {
        if (bankID == null || bankID == DBNull.Value) return "";
        int bid;
        if (!int.TryParse(bankID.ToString(), out bid) || bid == 0) return "";
        DataTable dt = ExecuteQuery("SELECT bank_name FROM banks WHERE bank_id = @id", new MySqlParameter("@id", bid));
        if (dt.Rows.Count > 0) return dt.Rows[0]["bank_name"].ToString();
        return bankID.ToString();
    }

    private void AddBioItem(StringBuilder sb, string label, object value)
    {
        string val = (value != null && value != DBNull.Value && value.ToString().Trim().Length > 0)
            ? HttpUtility.HtmlEncode(value.ToString()) : "<span style='color:#bbb;'>&mdash;</span>";
        sb.AppendFormat("<div class='ep-bio-item'><div class='ep-bio-label'>{0}</div><div class='ep-bio-value'>{1}</div></div>",
            HttpUtility.HtmlEncode(label), val);
    }

    private string GetActionButtonsHtml(string empID, string empName, string username, string email)
    {
        string dotsSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='5' r='1'/><circle cx='12' cy='12' r='1'/><circle cx='12' cy='19' r='1'/></svg>";
        string viewSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/></svg>";
        string editSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M12 20h9'/><path d='M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z'/></svg>";
        string pwdSvg  = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><rect x='3' y='11' width='18' height='11' rx='2' ry='2'/><path d='M7 11V7a5 5 0 0 1 10 0v4'/></svg>";
        string delSvg  = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='3 6 5 6 21 6'/><path d='M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2'/></svg>";

        string eName = empName.Replace("\\", "\\\\").Replace("'", "\\'");
        string uName = username.Replace("\\", "\\\\").Replace("'", "\\'");
        if (uName == "-") uName = "";
        string eEmail = email.Replace("\\", "\\\\").Replace("'", "\\'");
        string displayUser = string.IsNullOrEmpty(uName) ? eEmail : uName;

        return "<div class='cd-action-wrapper'>" +
            "<button type='button' class='cd-action-trigger' onclick='toggleActionPopover(this,event)'>" + dotsSvg + "</button>" +
            "<div class='cd-action-popover'>" +
            "<ul class='cd-action-popover__menu'>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--view' onclick=\"openEmployeeProfile(" + empID + ")\">" + viewSvg + " View Profile</button></li>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--edit' onclick=\"openEditModal(" + empID + ")\">" + editSvg + " Edit</button></li>" +
            "<li class='cd-action-popover__divider'></li>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn' onclick=\"openPasswordModal(" + empID + ",'" + eName + "','" + displayUser + "')\">" + pwdSvg + " Change Password</button></li>" +
            "<li class='cd-action-popover__divider'></li>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--danger' onclick=\"confirmDelete(" + empID + ",'" + eName + "')\">" + delSvg + " Delete</button></li>" +
            "</ul></div></div>";
    }

    private void ShowResult(string resultId, string modalId, string message, bool success)
    {
        string color = success ? "#28a745" : "#d32f2f";
        string js = string.Format(
            "var r=document.getElementById('{0}');if(r){{r.innerHTML='<span style=\"color:{1};\">{2}</span>';}}",
            resultId, color, HttpUtility.JavaScriptStringEncode(message));
        if (!string.IsNullOrEmpty(modalId))
            js += string.Format("document.getElementById('{0}').style.display='flex';", modalId);
        ScriptManager.RegisterStartupScript(this, GetType(), "result_" + DateTime.Now.Ticks, js, true);
    }

    /// <summary>POST-REDIRECT-GET: redirect after successful mutation to prevent re-submit on refresh.</summary>
    private void RedirectWithFlash(string message, bool success)
    {
        string url = BuildFilterUrl("msg=" + HttpUtility.UrlEncode(message) + "&ok=" + (success ? "1" : "0"));
        // Remove trailing '&' if present
        url = url.TrimEnd('&');
        Response.Redirect(url, true);
    }

    /// <summary>Show flash message from query string after a POST-REDIRECT-GET cycle.</summary>
    private void ShowFlashMessage()
    {
        string msg = (Request.QueryString["msg"] ?? "").Trim();
        if (string.IsNullOrEmpty(msg)) return;
        bool ok = (Request.QueryString["ok"] ?? "") == "1";
        string color = ok ? "#28a745" : "#d32f2f";
        string js = string.Format(
            "var r=document.getElementById('empFormResult');" +
            "var b=document.createElement('div');" +
            "b.className='hr-flash-msg';" +
            "b.style.cssText='padding:12px 20px;margin-bottom:14px;border-radius:6px;font-size:13px;font-weight:500;" +
            "background:{0};color:#fff;display:flex;align-items:center;gap:8px;animation:modalSlide .3s ease-out;';" +
            "b.innerHTML='{1}<button onclick=\"this.parentNode.remove()\" style=\"margin-left:auto;background:none;border:none;color:#fff;font-size:18px;cursor:pointer;\">&times;</button>';" +
            "var card=document.querySelector('.cd-card');" +
            "if(card)card.parentNode.insertBefore(b,card);" +
            "setTimeout(function(){{if(b.parentNode)b.remove();}},6000);",
            ok ? "#28a745" : "#d32f2f",
            HttpUtility.JavaScriptStringEncode(msg));
        ScriptManager.RegisterStartupScript(this, GetType(), "flash_" + DateTime.Now.Ticks, js, true);
    }

    private void SelectByValue(DropDownList ddl, string value)
    {
        if (string.IsNullOrEmpty(value)) return;
        ListItem item = ddl.Items.FindByValue(value);
        if (item != null) ddl.SelectedValue = value;
    }

    private int SafeInt(string val)
    {
        int v;
        if (int.TryParse(val, out v)) return v;
        return 0;
    }

    private string EscapeJson(object val)
    {
        if (val == null) return "";
        string s = val.ToString();
        StringBuilder sb = new StringBuilder(s.Length);
        foreach (char c in s)
        {
            switch (c)
            {
                case '\\': sb.Append("\\\\"); break;
                case '"':  sb.Append("\\\""); break;
                case '\n': sb.Append("\\n");  break;
                case '\r': sb.Append("\\r");  break;
                case '\t': sb.Append("\\t");  break;
                default:
                    if (c < 0x20) sb.AppendFormat("\\u{0:X4}", (int)c);
                    else sb.Append(c);
                    break;
            }
        }
        return sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  DATA ACCESS
    // ═══════════════════════════════════════════════════════════════════════════
    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private List<MySqlParameter> CloneParams(List<MySqlParameter> parms)
    {
        var clone = new List<MySqlParameter>();
        foreach (MySqlParameter p in parms)
            clone.Add(new MySqlParameter(p.ParameterName, p.Value));
        return clone;
    }

    private MySqlParameter[] CloneParams(MySqlParameter[] parms)
    {
        if (parms == null) return new MySqlParameter[0];
        MySqlParameter[] clone = new MySqlParameter[parms.Length];
        for (int i = 0; i < parms.Length; i++)
            clone[i] = new MySqlParameter(parms[i].ParameterName, parms[i].Value);
        return clone;
    }
}
