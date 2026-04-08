using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_HRContracts : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─── Query-string helpers ──────────────────────────────────────────────────
    private int    QsPage   { get { int v; return int.TryParse(Request.QueryString["page"]   ?? "1",  out v) && v > 0 ? v : 1; } }
    private string QsSearch { get { return (Request.QueryString["q"]      ?? "").Trim(); } }
    private string QsStatus { get { return (Request.QueryString["status"] ?? "").Trim().ToUpper(); } }
    private string QsType   { get { return (Request.QueryString["type"]   ?? "").Trim().ToUpper(); } }
    private string QsDept   { get { return (Request.QueryString["dept"]   ?? "").Trim(); } }
    private string QsJob    { get { return (Request.QueryString["job"]    ?? "").Trim(); } }
    private int    QsSize
    {
        get
        {
            int v;
            if (int.TryParse(Request.QueryString["sz"] ?? "50", out v) && v > 0) return v;
            return 50;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX search requests
        if (Request.QueryString["ajax"] == "search_emp")
        {
            HandleEmployeeSearch();
            return;
        }

        LoadFormDropdowns(); // must run every request so modal dropdowns survive postback
        if (!IsPostBack)
        {
            LoadFilterDropdowns();
            BindGrid();
            LoadStats();
            EmitEmployeeAutoFillScript();
            ShowFlashMessage();
        }
    }

    // ─── AJAX: Employee Search ─────────────────────────────────────────────────
    private void HandleEmployeeSearch()
    {
        Response.ContentType = "application/json";
        string query = (Request.QueryString["q"] ?? "").Trim();

        if (query.Length < 1)
        {
            Response.Write("{\"results\":[]}");
            Response.End();
            return;
        }

        try
        {
            DataTable dt = ExecuteQuery(
                @"SELECT e.empID, e.emp_name, e.EMP_CODE,
                         IFNULL(j.jobname, 'Staff') AS emp_position
                FROM hrm_employee e
                LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
                    AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
                LEFT JOIN hrm_jobs j ON j.ID = c.jobID
                WHERE e.emp_name LIKE @q OR e.EMP_CODE LIKE @q
                ORDER BY e.emp_name LIMIT 15",
                new MySqlParameter("@q", "%" + query + "%"));

            var list = new List<string>();
            foreach (DataRow row in dt.Rows)
            {
                list.Add("{\"empID\":\"" + EscapeJson(row["empID"]) +
                    "\",\"emp_name\":\"" + EscapeJson(row["emp_name"]) +
                    "\",\"EMP_CODE\":\"" + EscapeJson(row["EMP_CODE"]) +
                    "\",\"emp_position\":\"" + EscapeJson(row["emp_position"]) + "\"}");
            }
            Response.Write("{\"results\":[" + string.Join(",", list) + "]}");
            Response.End();
        }
        catch
        {
            Response.Write("{\"results\":[]}");
            Response.End();
        }
    }

    private string EscapeJson(object val)
    {
        if (val == null) return "";
        return val.ToString()
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\r", "\\r")
            .Replace("\n", "\\n")
            .Replace("\t", "\\t");
    }

    // ─── Populate filter dropdowns (reflects current QS selections) ───────────
    private void LoadFilterDropdowns()
    {
        ddlFilterStatus.Items.Clear();
        ddlFilterStatus.Items.Add(new System.Web.UI.WebControls.ListItem("All Statuses", ""));
        ddlFilterStatus.Items.Add(new System.Web.UI.WebControls.ListItem("Valid",      "VALID"));
        ddlFilterStatus.Items.Add(new System.Web.UI.WebControls.ListItem("Expiring",   "EXPIRING"));
        ddlFilterStatus.Items.Add(new System.Web.UI.WebControls.ListItem("Expired",    "EXPIRED"));
        ddlFilterStatus.Items.Add(new System.Web.UI.WebControls.ListItem("Terminated", "TERMINATED"));
        ddlFilterStatus.Items.Add(new System.Web.UI.WebControls.ListItem("Resigned",   "RESIGNED"));
        SelectByValue(ddlFilterStatus, QsStatus);

        ddlFilterType.Items.Clear();
        ddlFilterType.Items.Add(new System.Web.UI.WebControls.ListItem("All Types",  ""));
        ddlFilterType.Items.Add(new System.Web.UI.WebControls.ListItem("Full Time",  "FULL TIME"));
        ddlFilterType.Items.Add(new System.Web.UI.WebControls.ListItem("Part Time",  "PART TIME"));
        ddlFilterType.Items.Add(new System.Web.UI.WebControls.ListItem("Contract",   "CONTRACT"));
        ddlFilterType.Items.Add(new System.Web.UI.WebControls.ListItem("Temporary",  "TEMPORARY"));
        SelectByValue(ddlFilterType, QsType);

        DataTable dtDept = ExecuteQuery(
            "SELECT ID AS deptID, dept_name FROM hrm_departments WHERE dept_name IS NOT NULL ORDER BY dept_name");
        ddlFilterDept.Items.Clear();
        ddlFilterDept.Items.Add(new System.Web.UI.WebControls.ListItem("All Departments", ""));
        foreach (DataRow dr in dtDept.Rows)
            ddlFilterDept.Items.Add(new System.Web.UI.WebControls.ListItem(dr["dept_name"].ToString(), dr["deptID"].ToString()));
        SelectByValue(ddlFilterDept, QsDept);

        DataTable dtJob = ExecuteQuery(
            "SELECT ID AS jobID, jobname FROM hrm_jobs WHERE jobname IS NOT NULL ORDER BY jobname");
        ddlFilterJob.Items.Clear();
        ddlFilterJob.Items.Add(new System.Web.UI.WebControls.ListItem("All Jobs", ""));
        foreach (DataRow dr in dtJob.Rows)
            ddlFilterJob.Items.Add(new System.Web.UI.WebControls.ListItem(dr["jobname"].ToString(), dr["jobID"].ToString()));
        SelectByValue(ddlFilterJob, QsJob);

        ddlPageSize.Items.Clear();
        foreach (string sz in new string[] { "10", "25", "50", "100" })
            ddlPageSize.Items.Add(new System.Web.UI.WebControls.ListItem(sz + " per page", sz));
        SelectByValue(ddlPageSize, QsSize.ToString());

        txtSearch.Text = QsSearch;
    }

    // ─── Populate form dropdowns (Add / Edit / Renew modals) ──────────────────
    private void LoadFormDropdowns()
    {
        DataTable dtJob = ExecuteQuery("SELECT ID AS jobID, jobname FROM hrm_jobs ORDER BY jobname");
        ddlContractJob.Items.Clear();
        ddlContractJob.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Job --", ""));
        foreach (DataRow dr in dtJob.Rows)
            ddlContractJob.Items.Add(new System.Web.UI.WebControls.ListItem(dr["jobname"].ToString(), dr["jobID"].ToString()));

        DataTable dtDept = ExecuteQuery("SELECT ID AS deptID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlContractDept.Items.Clear();
        ddlContractDept.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Department --", ""));
        foreach (DataRow dr in dtDept.Rows)
            ddlContractDept.Items.Add(new System.Web.UI.WebControls.ListItem(dr["dept_name"].ToString(), dr["deptID"].ToString()));

        DataTable dtScale = ExecuteQuery(
            "SELECT ID AS scaleID, CONCAT(scale_name,' \x2013 UGX ',FORMAT(IFNULL(basicpay,0),0)) AS scaleLabel FROM hrm_payscales ORDER BY scale_name");
        ddlContractScale.Items.Clear();
        ddlContractScale.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Pay Scale --", ""));
        foreach (DataRow dr in dtScale.Rows)
            ddlContractScale.Items.Add(new System.Web.UI.WebControls.ListItem(dr["scaleLabel"].ToString(), dr["scaleID"].ToString()));

        // Edit modal dropdowns
        ddlEditJob.Items.Clear();
        ddlEditJob.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Job --", ""));
        foreach (DataRow dr in dtJob.Rows)
            ddlEditJob.Items.Add(new System.Web.UI.WebControls.ListItem(dr["jobname"].ToString(), dr["jobID"].ToString()));

        ddlEditDept.Items.Clear();
        ddlEditDept.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Department --", ""));
        foreach (DataRow dr in dtDept.Rows)
            ddlEditDept.Items.Add(new System.Web.UI.WebControls.ListItem(dr["dept_name"].ToString(), dr["deptID"].ToString()));

        ddlEditScale.Items.Clear();
        ddlEditScale.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Pay Scale --", ""));
        foreach (DataRow dr in dtScale.Rows)
            ddlEditScale.Items.Add(new System.Web.UI.WebControls.ListItem(dr["scaleLabel"].ToString(), dr["scaleID"].ToString()));

        ddlEditStatus.Items.Clear();
        foreach (string s in new string[] { "VALID", "EXPIRED", "TERMINATED", "RESIGNED" })
            ddlEditStatus.Items.Add(new System.Web.UI.WebControls.ListItem(s, s));

        ddlEditType.Items.Clear();
        foreach (string t in new string[] { "FULL TIME", "PART TIME", "CONTRACT", "TEMPORARY" })
            ddlEditType.Items.Add(new System.Web.UI.WebControls.ListItem(t, t));
    }

    private void EmitEmployeeAutoFillScript()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT e.empID,
                     IFNULL(c.jobID,       0) AS lastJobID,
                     IFNULL(c.departmentID, 0) AS lastDeptID,
                     IFNULL(c.payscale, 0) AS lastScaleID
              FROM hrm_employee e
              LEFT JOIN hrm_emp_contracts c
                ON c.empID = e.empID AND c.contractStatus = 'VALID'
              GROUP BY e.empID");

        var sb = new StringBuilder("var employeeDefaults={");
        bool first = true;
        foreach (DataRow dr in dt.Rows)
        {
            if (!first) sb.Append(",");
            first = false;
            sb.AppendFormat("{0}:{{j:{1},d:{2},s:{3}}}",
                dr["empID"], dr["lastJobID"], dr["lastDeptID"], dr["lastScaleID"]);
        }
        sb.Append("};");
        ScriptManager.RegisterStartupScript(this, GetType(), "empDefaults", sb.ToString(), true);
    }

    // ─── Stats bar ─────────────────────────────────────────────────────────────
    private void LoadStats()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN contractStatus='VALID' AND DATEDIFF(contractEnd, CURDATE()) > 90 THEN 1 ELSE 0 END) AS valid_ok,
                SUM(CASE WHEN contractStatus='VALID' AND DATEDIFF(contractEnd, CURDATE()) BETWEEN 1 AND 90 THEN 1 ELSE 0 END) AS expiring,
                SUM(CASE WHEN contractStatus IN ('EXPIRED','TERMINATED','RESIGNED') THEN 1 ELSE 0 END) AS expired,
                (SELECT COUNT(DISTINCT e2.empID) FROM hrm_employee e2
                 WHERE NOT EXISTS (
                   SELECT 1 FROM hrm_emp_contracts cc WHERE cc.empID=e2.empID AND cc.contractStatus='VALID')
                ) AS no_contract
              FROM hrm_emp_contracts");

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litStatTotal.Text      = r["total"].ToString();
            litStatValid.Text      = r["valid_ok"].ToString();
            litStatExpiring.Text   = r["expiring"].ToString();
            litStatExpired.Text    = r["expired"].ToString();
            litStatNoContract.Text = r["no_contract"].ToString();

            int exp = SafeInt(r["expiring"]);
            litExpiryBanner.Text = exp > 0
                ? String.Format(
                    "<div class='ct-banner'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'/><line x1='12' y1='9' x2='12' y2='13'/><line x1='12' y1='17' x2='12.01' y2='17'/></svg>" +
                    "<strong>{0} contract{1}</strong> expiring within 90 days. Review and renew promptly." +
                    "</div>", exp, exp == 1 ? "" : "s")
                : "";
        }
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int i; return int.TryParse(val.ToString(), out i) ? i : 0;
    }

    // ─── Main grid bind (GET-based pagination) ─────────────────────────────────
    private void BindGrid()
    {
        int    page   = QsPage;
        int    sz     = QsSize;
        int    offset = (page - 1) * sz;
        string search = QsSearch;
        string status = QsStatus;
        string type   = QsType;
        string dept   = QsDept;
        string job    = QsJob;

        var where = new StringBuilder("WHERE 1=1");
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(search))
        {
            where.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search OR c.comments LIKE @search)");
            parms.Add(new MySqlParameter("@search", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(dept))
        {
            where.Append(" AND d.ID = @dept");
            parms.Add(new MySqlParameter("@dept", dept));
        }
        if (!string.IsNullOrEmpty(job))
        {
            where.Append(" AND j.ID = @job");
            parms.Add(new MySqlParameter("@job", job));
        }
        if (!string.IsNullOrEmpty(type))
        {
            where.Append(" AND c.contract_type = @type");
            parms.Add(new MySqlParameter("@type", type));
        }
        if (status == "EXPIRING")
            where.Append(" AND c.contractStatus='VALID' AND DATEDIFF(c.contractEnd, CURDATE()) BETWEEN 1 AND 90");
        else if (!string.IsNullOrEmpty(status))
        {
            where.Append(" AND c.contractStatus = @status");
            parms.Add(new MySqlParameter("@status", status));
        }

        string countSql = String.Format(
            @"SELECT COUNT(*) FROM hrm_emp_contracts c
              JOIN  hrm_employee    e ON e.empID   = c.empID
              LEFT JOIN hrm_jobs    j ON j.ID = c.jobID
              LEFT JOIN hrm_departments d ON d.ID = c.departmentID
              {0}", where);

        int totalRows = 0;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(countSql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.Add(CloneParam(p));
                    totalRows = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
        }
        catch { }

        int totalPages = (int)Math.Ceiling((double)totalRows / sz);
        if (page > totalPages && totalPages > 0) page = totalPages;

        string rowsSql = String.Format(
            @"SELECT c.ID AS contractID, c.contractStart, c.contractEnd,
                     c.contractStatus, c.contract_type, c.comments,
                     c.fixedamount, c.payscale AS payscaleID,
                     e.empID, e.EMP_CODE, e.emp_name,
                     j.jobname, j.ID AS jobIDVal,
                     d.dept_name, d.ID AS deptIDVal,
                     ps.scale_name, ps.ID AS scaleIDVal,
                     IFNULL(ps.basicpay, c.fixedamount) AS basicpay,
                     DATEDIFF(c.contractEnd, CURDATE()) AS days_remaining
              FROM hrm_emp_contracts c
              JOIN hrm_employee e ON e.empID = c.empID
              LEFT JOIN hrm_jobs j ON j.ID = c.jobID
              LEFT JOIN hrm_departments d ON d.ID = c.departmentID
              LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
              {0}
              ORDER BY e.emp_name ASC, c.contractEnd DESC
              LIMIT @limit OFFSET @offset", where);

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(rowsSql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.Add(CloneParam(p));
                    cmd.Parameters.AddWithValue("@limit",  sz);
                    cmd.Parameters.AddWithValue("@offset", offset);

                    var sb = new StringBuilder();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        int rowNum = 0;
                        while (rdr.Read())
                        {
                            rowNum++;
                            string rowCss = GetRowCss(rdr["contractStatus"], rdr["days_remaining"]);
                            string cid    = rdr["contractID"].ToString();

                            sb.Append("<tr class='ct-row " + rowCss + "'>");
                            sb.AppendFormat("<td class='ct-col-chk'><input type='checkbox' class='ct-row-check' value='{0}' onchange='updateBatchToolbar()' /></td>", cid);
                            sb.AppendFormat("<td class='ct-col-num'>{0}</td>", offset + rowNum);
                            sb.AppendFormat("<td class='ct-col-emp'><span class='ct-emp-code'>{0}</span><br/><span class='ct-emp-name'>{1}</span></td>",
                                HttpUtility.HtmlEncode(rdr["EMP_CODE"].ToString()),
                                HttpUtility.HtmlEncode(rdr["emp_name"].ToString()));
                            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(rdr["dept_name"].ToString()));
                            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(rdr["jobname"].ToString()));
                            sb.AppendFormat("<td>{0}</td>", GetContractTypeBadge(rdr["contract_type"]));
                            sb.AppendFormat("<td>{0}</td>", GetStatusBadge(rdr["contractStatus"]));
                            sb.AppendFormat("<td class='ct-col-date'>{0}</td>", FormatDate(rdr["contractStart"]));
                            sb.AppendFormat("<td class='ct-col-date'>{0}</td>", FormatDate(rdr["contractEnd"]));
                            sb.AppendFormat("<td class='ct-col-days'>{0}</td>", GetDaysRemainingHtml(rdr["contractEnd"], rdr["contractStatus"]));
                            sb.AppendFormat("<td class='ct-col-pay'>{0}<br/><span class='ct-scale-name'>{1}</span></td>",
                                FormatCurrency(rdr["basicpay"]),
                                HttpUtility.HtmlEncode(rdr["scale_name"] == DBNull.Value ? "Fixed" : rdr["scale_name"].ToString()));
                            sb.AppendFormat("<td class='ct-col-actions'>{0}</td>",
                                GetActionButtonsHtml(rdr["contractID"], rdr["emp_name"], rdr["contractStatus"],
                                    rdr["empID"], rdr["contract_type"],
                                    rdr["jobIDVal"], rdr["deptIDVal"], rdr["scaleIDVal"],
                                    rdr["fixedamount"], rdr["contractStart"], rdr["contractEnd"], rdr["comments"]));
                            sb.Append("</tr>");
                        }
                        if (rowNum == 0)
                            sb.Append("<tr><td colspan='12' class='ct-empty-state'><div>No contracts found matching your filters.</div></td></tr>");
                    }
                    litGridBody.Text = sb.ToString();
                }
            }
        }
        catch (Exception ex)
        {
            litGridBody.Text = "<tr><td colspan='12' class='ct-empty-state'><div>Error loading data: " +
                HttpUtility.HtmlEncode(ex.Message) + "</div></td></tr>";
        }

        litPager.Text     = BuildPager(page, totalPages);
        litPagerInfo.Text = BuildPagerInfo(page, sz, totalRows, offset);
        litTotalCount.Text= totalRows.ToString();
    }

    private string BuildPagerInfo(int page, int sz, int total, int offset)
    {
        if (total == 0) return "No records";
        int from = offset + 1;
        int to   = Math.Min(offset + sz, total);
        return String.Format("Showing <strong>{0}&#x2013;{1}</strong> of <strong>{2}</strong> contracts", from, to, total);
    }

    private string BuildPager(int page, int totalPages)
    {
        if (totalPages <= 1) return "";
        var qs = new StringBuilder();
        if (!string.IsNullOrEmpty(QsSearch)) qs.AppendFormat("&amp;q={0}",      HttpUtility.UrlEncode(QsSearch));
        if (!string.IsNullOrEmpty(QsStatus)) qs.AppendFormat("&amp;status={0}", HttpUtility.UrlEncode(QsStatus));
        if (!string.IsNullOrEmpty(QsType))   qs.AppendFormat("&amp;type={0}",   HttpUtility.UrlEncode(QsType));
        if (!string.IsNullOrEmpty(QsDept))   qs.AppendFormat("&amp;dept={0}",   HttpUtility.UrlEncode(QsDept));
        if (!string.IsNullOrEmpty(QsJob))    qs.AppendFormat("&amp;job={0}",    HttpUtility.UrlEncode(QsJob));
        if (QsSize != 50)                    qs.AppendFormat("&amp;sz={0}",     QsSize);
        string baseQs = qs.ToString();

        var sb = new StringBuilder("<div class='ct-pager'>");
        sb.AppendFormat(page == 1
            ? "<span class='ct-pager__item ct-pager__item--disabled'>&laquo;</span>"
            : "<a href='?page=1{0}' class='ct-pager__item'>&laquo;</a>", baseQs);
        sb.AppendFormat(page == 1
            ? "<span class='ct-pager__item ct-pager__item--disabled'>&lsaquo;</span>"
            : "<a href='?page={0}{1}' class='ct-pager__item'>&lsaquo;</a>", page - 1, baseQs);

        int win = 2;
        int start = Math.Max(1, page - win);
        int end   = Math.Min(totalPages, page + win);

        if (start > 1)
        {
            sb.AppendFormat("<a href='?page=1{0}' class='ct-pager__item'>1</a>", baseQs);
            if (start > 2) sb.Append("<span class='ct-pager__ellipsis'>&hellip;</span>");
        }
        for (int i = start; i <= end; i++)
            sb.AppendFormat(i == page
                ? "<span class='ct-pager__item ct-pager__item--active'>{0}</span>"
                : "<a href='?page={0}{1}' class='ct-pager__item'>{0}</a>", i, baseQs);
        if (end < totalPages)
        {
            if (end < totalPages - 1) sb.Append("<span class='ct-pager__ellipsis'>&hellip;</span>");
            sb.AppendFormat("<a href='?page={0}{1}' class='ct-pager__item'>{0}</a>", totalPages, baseQs);
        }

        sb.AppendFormat(page == totalPages
            ? "<span class='ct-pager__item ct-pager__item--disabled'>&rsaquo;</span>"
            : "<a href='?page={0}{1}' class='ct-pager__item'>&rsaquo;</a>", page + 1, baseQs);
        sb.AppendFormat(page == totalPages
            ? "<span class='ct-pager__item ct-pager__item--disabled'>&raquo;</span>"
            : "<a href='?page={0}{1}' class='ct-pager__item'>&raquo;</a>", totalPages, baseQs);

        sb.Append("</div>");
        return sb.ToString();
    }

    // ─── Add Contract ──────────────────────────────────────────────────────────
    protected void btnAddContract_Click(object sender, EventArgs e)
    {
        int    empID   = SafeInt(Request.Form[hfSelectedEmpID.UniqueID]);
        int    jobID   = SafeInt(Request.Form[ddlContractJob.UniqueID]);
        int    deptID  = SafeInt(Request.Form[ddlContractDept.UniqueID]);
        int    scaleID = SafeInt(Request.Form[ddlContractScale.UniqueID]);
        string type    = Request.Form[ddlContractType.UniqueID] ?? "";
        string comment = txtContractComment.Text.Trim();
        string start   = txtContractStart.Text.Trim();
        string end     = txtContractEnd.Text.Trim();
        decimal fixed_ = 0;
        decimal.TryParse(txtContractFixed.Text.Trim(), out fixed_);

        if (empID <= 0)
        { ShowResult("addResult", "addModal", "Please select an employee.", false); return; }
        if (jobID <= 0)
        { ShowResult("addResult", "addModal", "Please select a job title.", false); return; }
        if (deptID <= 0)
        { ShowResult("addResult", "addModal", "Please select a department.", false); return; }
        if (scaleID <= 0)
        { ShowResult("addResult", "addModal", "Please select a pay scale.", false); return; }

        DateTime dtStart, dtEnd;
        if (!DateTime.TryParse(start, out dtStart) || !DateTime.TryParse(end, out dtEnd))
        { ShowResult("addResult", "addModal", "Invalid date range.", false); return; }
        if (dtEnd <= dtStart)
        { ShowResult("addResult", "addModal", "End date must be after start date.", false); return; }

        DataTable dup = ExecuteQuery(
            "SELECT ID FROM hrm_emp_contracts WHERE empID=@eid AND contractStatus='VALID' LIMIT 1",
            new MySqlParameter("@eid", empID));
        if (dup.Rows.Count > 0)
        { ShowResult("addResult", "addModal", "This employee already has an active (VALID) contract. Use Renew instead.", false); return; }

        ExecuteNonQuery(
            @"INSERT INTO hrm_emp_contracts
              (empID, jobID, departmentID, payscale, contract_type, contractStart, contractEnd,
               contractStatus, fixedamount, comments)
              VALUES (@eid,@jid,@did,@sid,@type,@start,@end,'VALID',@fixed,@cmnt)",
            new MySqlParameter("@eid",   empID),
            new MySqlParameter("@jid",   jobID),
            new MySqlParameter("@did",   deptID),
            new MySqlParameter("@sid",   scaleID),
            new MySqlParameter("@type",  string.IsNullOrEmpty(type) ? "FULL TIME" : type),
            new MySqlParameter("@start", dtStart),
            new MySqlParameter("@end",   dtEnd),
            new MySqlParameter("@fixed", fixed_ > 0 ? (object)fixed_ : DBNull.Value),
            new MySqlParameter("@cmnt",  string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment));

        RedirectWithFlash("Contract added successfully.", true);
    }

    // ─── Renew Contract ────────────────────────────────────────────────────────
    protected void btnRenewContract_Click(object sender, EventArgs e)
    {
        int    origID = SafeInt(hdnRenewContractID.Value);
        int    empID  = SafeInt(hdnRenewEmpID.Value);
        string start  = txtRenewStart.Text.Trim();
        string end    = txtRenewEnd.Text.Trim();
        string type   = Request.Form[ddlRenewType.UniqueID] ?? "";

        if (origID <= 0 || empID <= 0)
        { ShowResult("renewResult", "renewModal", "Invalid renewal data.", false); return; }

        DateTime dtStart, dtEnd;
        if (!DateTime.TryParse(start, out dtStart) || !DateTime.TryParse(end, out dtEnd))
        { ShowResult("renewResult", "renewModal", "Invalid date range.", false); return; }
        if (dtEnd <= dtStart)
        { ShowResult("renewResult", "renewModal", "End date must be after start date.", false); return; }

        DataTable orig = ExecuteQuery(
            "SELECT jobID, departmentID, payscale, fixedamount FROM hrm_emp_contracts WHERE ID=@id",
            new MySqlParameter("@id", origID));
        if (orig.Rows.Count == 0)
        { ShowResult("renewResult", "renewModal", "Original contract not found.", false); return; }

        DataRow oRow   = orig.Rows[0];
        object  jobID  = oRow["jobID"]        == DBNull.Value ? DBNull.Value : oRow["jobID"];
        object  deptID = oRow["departmentID"] == DBNull.Value ? DBNull.Value : oRow["departmentID"];
        object  scale  = oRow["payscale"]   == DBNull.Value ? DBNull.Value : oRow["payscale"];
        object  fixed_ = oRow["fixedamount"]== DBNull.Value ? DBNull.Value : oRow["fixedamount"];

        ExecuteNonQuery("UPDATE hrm_emp_contracts SET contractStatus='EXPIRED' WHERE ID=@id",
            new MySqlParameter("@id", origID));

        ExecuteNonQuery(
            @"INSERT INTO hrm_emp_contracts
              (empID, jobID, departmentID, payscale, contract_type, contractStart, contractEnd,
               contractStatus, fixedamount)
              VALUES (@eid,@jid,@did,@sid,@type,@start,@end,'VALID',@fixed)",
            new MySqlParameter("@eid",   empID),
            new MySqlParameter("@jid",   jobID),
            new MySqlParameter("@did",   deptID),
            new MySqlParameter("@sid",   scale),
            new MySqlParameter("@type",  string.IsNullOrEmpty(type) ? "FULL TIME" : type),
            new MySqlParameter("@start", dtStart),
            new MySqlParameter("@end",   dtEnd),
            new MySqlParameter("@fixed", fixed_));

        RedirectWithFlash("Contract renewed successfully.", true);
    }

    // ─── Edit Contract ─────────────────────────────────────────────────────────
    protected void btnUpdateContract_Click(object sender, EventArgs e)
    {
        int     cid     = SafeInt(hdnEditContractID.Value);
        int     jobID   = SafeInt(Request.Form[ddlEditJob.UniqueID]);
        int     deptID  = SafeInt(Request.Form[ddlEditDept.UniqueID]);
        int     scaleID = SafeInt(Request.Form[ddlEditScale.UniqueID]);
        string  type    = Request.Form[ddlEditType.UniqueID]   ?? "";
        string  status  = Request.Form[ddlEditStatus.UniqueID] ?? "";
        string  start   = txtEditStart.Text.Trim();
        string  end     = txtEditEnd.Text.Trim();
        string  comment = txtEditComment.Text.Trim();
        decimal fixed_  = 0;
        decimal.TryParse(txtEditFixed.Text.Trim(), out fixed_);

        if (cid <= 0)
        { ShowResult("editResult", "editModal", "Invalid contract ID.", false); return; }
        if (jobID <= 0)
        { ShowResult("editResult", "editModal", "Please select a job title.", false); return; }
        if (deptID <= 0)
        { ShowResult("editResult", "editModal", "Please select a department.", false); return; }
        if (scaleID <= 0)
        { ShowResult("editResult", "editModal", "Please select a pay scale.", false); return; }

        DateTime dtStart, dtEnd;
        if (!DateTime.TryParse(start, out dtStart) || !DateTime.TryParse(end, out dtEnd))
        { ShowResult("editResult", "editModal", "Invalid date range.", false); return; }
        if (dtEnd <= dtStart)
        { ShowResult("editResult", "editModal", "End date must be after start date.", false); return; }

        ExecuteNonQuery(
            @"UPDATE hrm_emp_contracts SET
                jobID=@jid, departmentID=@did, payscale=@sid, contract_type=@type,
                contractStart=@start, contractEnd=@end, contractStatus=@status,
                fixedamount=@fixed, comments=@cmnt
              WHERE ID=@cid",
            new MySqlParameter("@jid",    jobID),
            new MySqlParameter("@did",    deptID),
            new MySqlParameter("@sid",    scaleID),
            new MySqlParameter("@type",   type),
            new MySqlParameter("@start",  dtStart),
            new MySqlParameter("@end",    dtEnd),
            new MySqlParameter("@status", status),
            new MySqlParameter("@fixed",  fixed_ > 0 ? (object)fixed_ : DBNull.Value),
            new MySqlParameter("@cmnt",   string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment),
            new MySqlParameter("@cid",    cid));

        RedirectWithFlash("Contract updated successfully.", true);
    }

    // ─── Delete Contract ───────────────────────────────────────────────────────
    protected void btnDeleteContract_Click(object sender, EventArgs e)
    {
        int cid = SafeInt(hdnDeleteContractID.Value);
        if (cid <= 0) return;
        ExecuteNonQuery("DELETE FROM hrm_emp_contracts WHERE ID=@id",
            new MySqlParameter("@id", cid));
        RedirectWithFlash("Contract deleted successfully.", true);
    }

    #region Batch Operations

    protected void btnBatchExpire_Click(object sender, EventArgs e)
    {
        string[] ids = GetBatchIDs();
        if (ids.Length == 0) return;

        foreach (string id in ids)
        {
            int cid;
            if (int.TryParse(id.Trim(), out cid))
                ExecuteNonQuery("UPDATE hrm_emp_contracts SET contractStatus='EXPIRED' WHERE ID=@id",
                    new MySqlParameter("@id", cid));
        }

        RedirectWithFlash(String.Format("{0} contract(s) expired.", ids.Length), true);
    }

    protected void btnBatchDelete_Click(object sender, EventArgs e)
    {
        string[] ids = GetBatchIDs();
        if (ids.Length == 0) return;

        foreach (string id in ids)
        {
            int cid;
            if (int.TryParse(id.Trim(), out cid))
                ExecuteNonQuery("DELETE FROM hrm_emp_contracts WHERE ID=@id",
                    new MySqlParameter("@id", cid));
        }

        RedirectWithFlash(String.Format("{0} contract(s) deleted.", ids.Length), true);
    }

    protected void btnBatchStatus_Click(object sender, EventArgs e)
    {
        string[] ids    = GetBatchIDs();
        string   status = (hdnBatchStatus.Value ?? "").Trim().ToUpper();

        string[] allowed = { "VALID", "EXPIRED", "TERMINATED", "RESIGNED" };
        if (ids.Length == 0 || string.IsNullOrEmpty(status) || !Array.Exists(allowed, s => s == status))
            return;

        foreach (string id in ids)
        {
            int cid;
            if (int.TryParse(id.Trim(), out cid))
                ExecuteNonQuery("UPDATE hrm_emp_contracts SET contractStatus=@status WHERE ID=@id",
                    new MySqlParameter("@status", status),
                    new MySqlParameter("@id",     cid));
        }

        RedirectWithFlash(String.Format("{0} contract(s) updated to {1}.", ids.Length, status), true);
    }

    private string[] GetBatchIDs()
    {
        string raw = hdnBatchIDs.Value ?? "";
        if (string.IsNullOrEmpty(raw)) return new string[0];
        return raw.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);
    }

    #endregion

    // ─── Template Helpers ──────────────────────────────────────────────────────
    private string GetRowCss(object statusObj, object daysObj)
    {
        string status = (statusObj != null && statusObj != DBNull.Value) ? statusObj.ToString().ToUpper() : "";
        if (status == "VALID")
        {
            int d;
            if (daysObj != null && daysObj != DBNull.Value && int.TryParse(daysObj.ToString(), out d))
                return d <= 90 ? "ct-row-expiring" : "ct-row-valid";
            return "ct-row-valid";
        }
        if (status == "EXPIRED" || status == "TERMINATED" || status == "RESIGNED")
            return "ct-row-expired";
        return "";
    }

    protected string GetContractTypeBadge(object type)
    {
        string t   = (type != null && type != DBNull.Value) ? type.ToString() : "FULL TIME";
        string css = t == "PART TIME" ? "ct-type--part"
                   : t == "CONTRACT"  ? "ct-type--contract"
                   : t == "TEMPORARY" ? "ct-type--temp"
                   : "ct-type--full";
        return String.Format("<span class='ct-type {0}'>{1}</span>", css, HttpUtility.HtmlEncode(t));
    }

    protected string GetStatusBadge(object status)
    {
        if (status == null || status == DBNull.Value)
            return "<span class='hr-badge hr-badge--none'>NONE</span>";
        string s   = status.ToString().ToUpper();
        string css = s == "VALID"      ? "hr-badge--valid"
                   : s == "EXPIRED"    ? "hr-badge--expired"
                   : s == "TERMINATED" ? "hr-badge--terminated"
                   : s == "RESIGNED"   ? "hr-badge--resigned"
                   : "hr-badge--none";
        return String.Format("<span class='hr-badge {0}'>{1}</span>", css, HttpUtility.HtmlEncode(s));
    }

    protected string GetDaysRemainingHtml(object endDateObj, object statusObj)
    {
        string status = (statusObj != null && statusObj != DBNull.Value) ? statusObj.ToString().ToUpper() : "";
        if (status != "VALID") return "<span class='ct-days--na'>-</span>";
        if (endDateObj == null || endDateObj == DBNull.Value) return "<span class='ct-days--na'>-</span>";
        DateTime endDate;
        if (!DateTime.TryParse(endDateObj.ToString(), out endDate)) return "<span class='ct-days--na'>-</span>";
        int days = (endDate - DateTime.Today).Days;
        if (days <= 0)  return "<span class='ct-days ct-days--over'>OVERDUE</span>";
        if (days <= 30) return String.Format("<span class='ct-days ct-days--urgent'>{0}d</span>", days);
        if (days <= 90) return String.Format("<span class='ct-days ct-days--warn'>{0}d</span>", days);
        return String.Format("<span class='ct-days ct-days--ok'>{0}d</span>", days);
    }

    protected string FormatCurrency(object val)
    {
        if (val == null || val == DBNull.Value) return "-";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d)) return d.ToString("N0");
        return val.ToString();
    }

    private string FormatDate(object d)
    {
        if (d == null || d == DBNull.Value) return "-";
        DateTime dt;
        if (DateTime.TryParse(d.ToString(), out dt)) return dt.ToString("dd MMM yyyy");
        return d.ToString();
    }

    private string GetActionButtonsHtml(object contractID, object empNameObj, object statusObj,
        object empIDObj, object contractTypeObj,
        object jobIDObj, object deptIDObj, object scaleIDObj,
        object fixedObj, object startObj, object endObj, object commentObj)
    {
        string cid          = contractID.ToString();
        string empID        = empIDObj != null ? empIDObj.ToString() : "";
        string empName      = (empNameObj != null ? empNameObj.ToString() : "").Replace("'", "\\'");
        string status       = (statusObj != null ? statusObj.ToString() : "").ToUpper();
        string contractType = (contractTypeObj != null ? contractTypeObj.ToString() : "FULL TIME");
        string jobID        = (jobIDObj  != null && jobIDObj  != DBNull.Value) ? jobIDObj.ToString()  : "";
        string deptID       = (deptIDObj != null && deptIDObj != DBNull.Value) ? deptIDObj.ToString() : "";
        string scaleID      = (scaleIDObj!= null && scaleIDObj!= DBNull.Value) ? scaleIDObj.ToString(): "";
        string fixedAmt     = (fixedObj  != null && fixedObj  != DBNull.Value) ? fixedObj.ToString()  : "0";
        string startDt      = (startObj  != null && startObj  != DBNull.Value) ? Convert.ToDateTime(startObj).ToString("yyyy-MM-dd") : "";
        string endDt        = (endObj    != null && endObj    != DBNull.Value) ? Convert.ToDateTime(endObj).ToString("yyyy-MM-dd")   : "";

        string dotsSvg  = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='5' r='1'/><circle cx='12' cy='12' r='1'/><circle cx='12' cy='19' r='1'/></svg>";
        string editSvg  = "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M12 20h9'/><path d='M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z'/></svg>";
        string delSvg   = "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='3 6 5 6 21 6'/><path d='M19 6l-1 14H6L5 6'/><path d='M10 11v6'/><path d='M14 11v6'/><path d='M9 6V4h6v2'/></svg>";
        string renewSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='23 4 23 10 17 10'/><polyline points='1 20 1 14 7 14'/><path d='M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15'/></svg>";

        string renewItem = "";
        if (status == "VALID" || status == "EXPIRED")
        {
            renewItem =
                "<li class='cd-action-popover__item'>" +
                String.Format("<button type='button' class='cd-action-popover__btn cd-action-popover__btn--success' " +
                "onclick=\"openRenewModal('{0}','{1}','{2}','{3}','{4}')\">", cid, empID, empName, endDt, contractType) +
                renewSvg + " Renew</button></li><li class='cd-action-popover__divider'></li>";
        }

        string commentJs   = (commentObj != null && commentObj != DBNull.Value)
                             ? commentObj.ToString().Replace("\\", "\\\\").Replace("'", "\\'") : "";
        string editClick   = String.Format("openEditModal('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}')",
            cid, jobID, deptID, scaleID, contractType, status, startDt, endDt, fixedAmt, commentJs, empName);
        string deleteClick = String.Format("confirmDelete('{0}','{1}')", cid, empName);

        return
            "<div class='cd-action-wrapper'>" +
            "<button type='button' class='cd-action-trigger' onclick='toggleActionPopover(this,event)'>" + dotsSvg + "</button>" +
            "<div class='cd-action-popover'><ul class='cd-action-popover__menu'>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn' onclick=\"" + editClick + "\">" + editSvg + " Edit</button></li>" +
            renewItem +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--danger' onclick=\"" + deleteClick + "\">" + delSvg + " Delete</button></li>" +
            "</ul></div></div>";
    }

    // ─── PRG Helpers ────────────────────────────────────────────────────────────
    private string BuildFilterUrl(string extra)
    {
        var parts = new List<string>();
        if (!string.IsNullOrEmpty(QsSearch))  parts.Add("q=" + HttpUtility.UrlEncode(QsSearch));
        if (!string.IsNullOrEmpty(QsStatus))  parts.Add("status=" + HttpUtility.UrlEncode(QsStatus));
        if (!string.IsNullOrEmpty(QsType))    parts.Add("type=" + HttpUtility.UrlEncode(QsType));
        if (!string.IsNullOrEmpty(QsDept))    parts.Add("dept=" + HttpUtility.UrlEncode(QsDept));
        if (!string.IsNullOrEmpty(QsJob))     parts.Add("job=" + HttpUtility.UrlEncode(QsJob));
        if (QsSize != 50)                     parts.Add("sz=" + QsSize);
        if (!string.IsNullOrEmpty(extra))     parts.Add(extra);
        string qs = string.Join("&", parts);
        return "HRContracts.aspx?" + (qs.Length > 0 ? qs + "&" : "");
    }

    private void RedirectWithFlash(string message, bool success)
    {
        string url = BuildFilterUrl("msg=" + HttpUtility.UrlEncode(message) + "&ok=" + (success ? "1" : "0"));
        url = url.TrimEnd('&');
        Response.Redirect(url, true);
    }

    /// <summary>Show flash message from query string after a POST-REDIRECT-GET cycle.</summary>
    private void ShowFlashMessage()
    {
        string msg = (Request.QueryString["msg"] ?? "").Trim();
        if (string.IsNullOrEmpty(msg)) return;
        bool ok = (Request.QueryString["ok"] ?? "") == "1";
        string js = string.Format(
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

    // ─── Helpers ───────────────────────────────────────────────────────────────
    private void ShowResult(string resultId, string modalId, string message, bool success)
    {
        string css = success ? "hr-result hr-result--ok" : "hr-result hr-result--err";
        ScriptManager.RegisterStartupScript(this, GetType(), "res_" + resultId,
            String.Format(
                "(function(){{var r=document.getElementById('{0}');if(r){{r.className='{1}';r.innerHTML='{2}';}};document.getElementById('{3}').style.display='flex';}})()",
                resultId, css, HttpUtility.JavaScriptStringEncode(message), modalId),
            true);
    }

    private void SelectByValue(System.Web.UI.WebControls.DropDownList ddl, string val)
    {
        var item = ddl.Items.FindByValue(val);
        if (item != null) item.Selected = true;
    }

    private MySqlParameter CloneParam(MySqlParameter p)
    {
        return new MySqlParameter(p.ParameterName, p.Value);
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
