using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_RequisitionsController : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string QsSearch  { get { return (Request.QueryString["q"]        ?? "").Trim(); } }
    private string QsStatus  { get { return (Request.QueryString["status"]   ?? "").Trim().ToUpper(); } }
    private string QsType    { get { return (Request.QueryString["req_type"] ?? "").Trim().ToUpper(); } }

    protected string Sel(string val)     { return QsStatus == val ? "selected" : ""; }
    protected string SelType(string val) { return QsType == val ? "selected" : ""; }

    private static bool _schemaChecked = false;

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureSchema();
        if (!IsPostBack) LoadAll();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SCHEMA
    // ═══════════════════════════════════════════════════════════════════
    private void EnsureSchema()
    {
        if (_schemaChecked) return;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                CreateTableIfMissing(conn, "sys_requisitions",
                    @"CREATE TABLE `sys_requisitions` (
                      `ID` INT NOT NULL AUTO_INCREMENT,`req_number` VARCHAR(20) NOT NULL,
                      `title` VARCHAR(255) NOT NULL,`description` TEXT,`req_type` VARCHAR(20) NOT NULL DEFAULT 'GOODS',
                      `priority` VARCHAR(10) NOT NULL DEFAULT 'MEDIUM',`status` VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
                      `total_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,`currency` VARCHAR(5) NOT NULL DEFAULT 'UGX',
                      `financial_year` VARCHAR(10),`period_label` VARCHAR(50),
                      `requester_id` INT,`requester_name` VARCHAR(150),`requester_email` VARCHAR(150),
                      `requester_phone` VARCHAR(30),`department` VARCHAR(150),`section` VARCHAR(100),
                      `supervisor_id` INT,`supervisor_name` VARCHAR(150),
                      `supervisor_action` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                      `supervisor_remarks` TEXT,`supervisor_at` DATETIME,
                      `bursar_action` VARCHAR(20) NOT NULL DEFAULT 'PENDING',`bursar_remarks` TEXT,
                      `bursar_route` VARCHAR(20) NOT NULL DEFAULT 'FINANCE',`bursar_processed_by` VARCHAR(150),`bursar_at` DATETIME,
                      `vc_action` VARCHAR(20) NOT NULL DEFAULT 'PENDING',`vc_remarks` TEXT,
                      `vc_processed_by` VARCHAR(150),`vc_at` DATETIME,
                      `procurement_status` VARCHAR(50),`procurement_remarks` TEXT,
                      `procurement_processed_by` VARCHAR(150),`procurement_at` DATETIME,`lpo_number` VARCHAR(50),
                      `finance_action` VARCHAR(20) NOT NULL DEFAULT 'PENDING',`finance_remarks` TEXT,
                      `finance_processed_by` VARCHAR(150),`finance_at` DATETIME,`payment_method` VARCHAR(30),
                      `payment_ref` VARCHAR(100),`payment_date` DATE,`ledger_ref` VARCHAR(100),
                      `ledger_posted` TINYINT(1) NOT NULL DEFAULT 0,`ledger_posted_at` DATETIME,
                      `submitted_at` DATETIME,`created_by` VARCHAR(100),
                      `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
                      PRIMARY KEY (`ID`),UNIQUE KEY `uq_req_number` (`req_number`),
                      KEY `idx_status` (`status`),KEY `idx_requester_id` (`requester_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                CreateTableIfMissing(conn, "sys_requisition_items",
                    @"CREATE TABLE `sys_requisition_items` (
                      `ID` INT NOT NULL AUTO_INCREMENT,`requisition_id` INT NOT NULL,
                      `item_no` INT NOT NULL DEFAULT 1,`description` VARCHAR(500) NOT NULL,
                      `unit` VARCHAR(30) NOT NULL DEFAULT 'pcs',`qty` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
                      `unit_price` DECIMAL(15,2) NOT NULL DEFAULT 0.00,`total_price` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                      `category` VARCHAR(100),`notes` TEXT,
                      `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      PRIMARY KEY (`ID`),KEY `idx_req_items` (`requisition_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                CreateTableIfMissing(conn, "sys_requisition_audit",
                    @"CREATE TABLE `sys_requisition_audit` (
                      `ID` INT NOT NULL AUTO_INCREMENT,`requisition_id` INT NOT NULL,
                      `action_code` VARCHAR(50) NOT NULL,`old_status` VARCHAR(30),`new_status` VARCHAR(30),
                      `actor_name` VARCHAR(150),`actor_role` VARCHAR(80),`remarks` TEXT,`ip_address` VARCHAR(45),
                      `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      PRIMARY KEY (`ID`),KEY `idx_audit_req` (`requisition_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            }
        }
        catch { /* tables already exist */ }
        _schemaChecked = true;
    }

    private void CreateTableIfMissing(MySqlConnection conn, string tableName, string createSql)
    {
        using (var cmd = new MySqlCommand("SHOW TABLES LIKE @t", conn))
        {
            cmd.Parameters.AddWithValue("@t", tableName);
            var result = cmd.ExecuteScalar();
            if (result == null || result == DBNull.Value)
            {
                using (var create = new MySqlCommand(createSql, conn))
                    create.ExecuteNonQuery();
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  LOAD ALL
    // ═══════════════════════════════════════════════════════════════════
    private void LoadAll()
    {
        LoadKpiAndCharts();
        LoadGrid();
    }

    private void LoadKpiAndCharts()
    {
        DataTable dtStats = ExecuteQuery(
            @"SELECT status, COUNT(*) AS cnt, COALESCE(SUM(total_amount),0) AS val
              FROM sys_requisitions WHERE is_deleted=0
              GROUP BY status");

        int total = 0, pipeline = 0, paid = 0, pendBursar = 0;
        decimal totalVal = 0;
        var statusLabels = new List<string>();
        var statusValues = new List<int>();

        var statusMap = new Dictionary<string, string>
        {
            {"DRAFT","Draft"},{"SUBMITTED","Awaiting Supervisor"},{"SUPERVISOR_APPROVED","Bursar Queue"},
            {"SUPERVISOR_REJECTED","Sup. Rejected"},{"BURSAR_REVIEW","Bursar Review"},{"BURSAR_APPROVED","Bursar Approved"},
            {"VC_PENDING","VC Pending"},{"VC_APPROVED","VC Approved"},{"VC_REJECTED","VC Rejected"},
            {"PROCUREMENT","Procurement"},{"PROCUREMENT_COMPLETE","Proc. Done"},
            {"FINANCE_REVIEW","Finance Review"},{"PAID_OUT","Paid Out"},{"PENDING_PAYMENT","Pending Pay."},
            {"RETURNED","Returned"},{"CANCELLED","Cancelled"}
        };

        var pipelineStatuses = new HashSet<string> {
            "SUBMITTED","SUPERVISOR_APPROVED","BURSAR_REVIEW","BURSAR_APPROVED",
            "VC_PENDING","VC_APPROVED","PROCUREMENT","PROCUREMENT_COMPLETE","FINANCE_REVIEW","PENDING_PAYMENT"
        };

        foreach (DataRow r in dtStats.Rows)
        {
            string st = SafeStr(r["status"]);
            int    cnt = SafeInt(r["cnt"]);
            decimal val = SafeDecimal(r["val"]);
            total += cnt;
            totalVal += val;
            if (st == "PAID_OUT")          paid += cnt;
            if (st == "SUPERVISOR_APPROVED") pendBursar += cnt;
            if (pipelineStatuses.Contains(st)) pipeline += cnt;

            string label = statusMap.ContainsKey(st) ? statusMap[st] : st;
            statusLabels.Add(label);
            statusValues.Add(cnt);
        }

        litKpiTotal.Text         = total.ToString();
        litKpiPipeline.Text      = pipeline.ToString();
        litKpiPaid.Text          = paid.ToString();
        litKpiValue.Text         = FormatUGX(totalVal);
        litKpiPendingBursar.Text = pendBursar.ToString();

        var jss = new JavaScriptSerializer();
        hfStatusLabels.Value = jss.Serialize(statusLabels);
        hfStatusValues.Value = jss.Serialize(statusValues);

        // By department
        DataTable dtDept = ExecuteQuery(
            @"SELECT COALESCE(NULLIF(TRIM(department),''),'Unknown') AS dept, COUNT(*) AS cnt
              FROM sys_requisitions WHERE is_deleted=0
              GROUP BY dept ORDER BY cnt DESC LIMIT 8");
        var deptL = new List<string>(); var deptV = new List<int>();
        foreach (DataRow r in dtDept.Rows) { deptL.Add(SafeStr(r["dept"])); deptV.Add(SafeInt(r["cnt"])); }
        hfDeptLabels.Value = jss.Serialize(deptL);
        hfDeptValues.Value = jss.Serialize(deptV);

        // By type
        DataTable dtType = ExecuteQuery(
            @"SELECT req_type, COUNT(*) AS cnt FROM sys_requisitions WHERE is_deleted=0 GROUP BY req_type ORDER BY cnt DESC");
        var typeL = new List<string>(); var typeV = new List<int>();
        foreach (DataRow r in dtType.Rows) { typeL.Add(SafeStr(r["req_type"])); typeV.Add(SafeInt(r["cnt"])); }
        hfTypeLabels.Value = jss.Serialize(typeL);
        hfTypeValues.Value = jss.Serialize(typeV);
    }

    private void LoadGrid()
    {
        string q      = QsSearch;
        string status = QsStatus;
        string type   = QsType;

        var parms = new List<MySqlParameter>();
        var where = new StringBuilder("WHERE r.is_deleted=0");
        if (!string.IsNullOrEmpty(q))
        {
            where.Append(" AND (r.req_number LIKE @q OR r.title LIKE @q OR r.requester_name LIKE @q OR r.department LIKE @q)");
            parms.Add(new MySqlParameter("@q", "%" + q + "%"));
        }
        if (!string.IsNullOrEmpty(status))
        {
            where.Append(" AND r.status=@st");
            parms.Add(new MySqlParameter("@st", status));
        }
        if (!string.IsNullOrEmpty(type))
        {
            where.Append(" AND r.req_type=@rt");
            parms.Add(new MySqlParameter("@rt", type));
        }

        DataTable dt = ExecuteQuery(
            "SELECT r.ID,r.req_number,r.title,r.req_type,r.priority,r.status,r.total_amount,r.requester_name,r.department,r.created_at,r.submitted_at " +
            "FROM sys_requisitions r " + where + " ORDER BY r.created_at DESC LIMIT 500",
            parms.ToArray());

        litTotalCount.Text = dt.Rows.Count.ToString();

        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            int     id       = SafeInt(r["ID"]);
            string  reqNo    = SafeStr(r["req_number"]);
            string  title    = SafeStr(r["title"]);
            string  reqType  = SafeStr(r["req_type"]);
            string  priority = SafeStr(r["priority"]);
            string  st       = SafeStr(r["status"]);
            decimal amount   = SafeDecimal(r["total_amount"]);
            string  requester= SafeStr(r["requester_name"]);
            string  dept     = SafeStr(r["department"]);
            string  dateStr  = r["created_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["created_at"]).ToString("dd MMM yyyy");

            string badge   = GetStatusBadge(st);
            string priHtml = GetPriDot(priority);

            sb.AppendFormat(
                "<tr><td class='rc-col-num'>{0}</td><td class='rc-nowrap'><strong>{1}</strong></td>" +
                "<td style='max-width:200px;'>{2}</td>" +
                "<td>{3}<div style='font-size:10px;color:#999;'>{4}</div></td>" +
                "<td style='font-size:10px;'>{5}</td><td>{6}</td>" +
                "<td class='rc-col-amt'>{7}</td><td>{8}</td><td class='rc-nowrap'>{9}</td>" +
                "<td class='rc-col-action'><a href='RequisitionDetail.aspx?id={10}' class='rc-btn rc-btn--primary' style='font-size:10px;'>View</a></td></tr>",
                n,
                HttpUtility.HtmlEncode(reqNo),
                HttpUtility.HtmlEncode(title.Length > 50 ? title.Substring(0, 50) + "…" : title),
                HttpUtility.HtmlEncode(requester), HttpUtility.HtmlEncode(dept),
                HttpUtility.HtmlEncode(reqType), priHtml,
                FormatUGX(amount), badge,
                HttpUtility.HtmlEncode(dateStr), id);
        }

        litGridRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='10' class='rc-empty'>No requisitions found.</td></tr>";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════
    private string GetStatusBadge(string status)
    {
        switch (status)
        {
            case "DRAFT":                return "<span class='rc-badge rc-badge--draft'>Draft</span>";
            case "SUBMITTED":            return "<span class='rc-badge rc-badge--submitted'>Supervisor Queue</span>";
            case "SUPERVISOR_APPROVED":  return "<span class='rc-badge rc-badge--bursar'>Bursar Queue</span>";
            case "SUPERVISOR_REJECTED":  return "<span class='rc-badge rc-badge--rejected'>Sup. Rejected</span>";
            case "BURSAR_REVIEW":        return "<span class='rc-badge rc-badge--bursar'>Bursar Review</span>";
            case "BURSAR_APPROVED":      return "<span class='rc-badge rc-badge--supervisor'>Bursar Approved</span>";
            case "VC_PENDING":           return "<span class='rc-badge rc-badge--vc'>VC Pending</span>";
            case "VC_APPROVED":          return "<span class='rc-badge rc-badge--supervisor'>VC Approved</span>";
            case "VC_REJECTED":          return "<span class='rc-badge rc-badge--rejected'>VC Rejected</span>";
            case "PROCUREMENT":          return "<span class='rc-badge rc-badge--procurement'>Procurement</span>";
            case "PROCUREMENT_COMPLETE": return "<span class='rc-badge rc-badge--supervisor'>Proc. Done</span>";
            case "FINANCE_REVIEW":       return "<span class='rc-badge rc-badge--finance'>Finance</span>";
            case "PAID_OUT":             return "<span class='rc-badge rc-badge--paid'>Paid Out</span>";
            case "PENDING_PAYMENT":      return "<span class='rc-badge rc-badge--pending-pay'>Pending Pay</span>";
            case "RETURNED":             return "<span class='rc-badge rc-badge--returned'>Returned</span>";
            case "CANCELLED":            return "<span class='rc-badge rc-badge--cancelled'>Cancelled</span>";
            default:                     return "<span class='rc-badge rc-badge--draft'>" + HttpUtility.HtmlEncode(status) + "</span>";
        }
    }

    private string GetPriDot(string priority)
    {
        string cls = "rc-dot--medium";
        switch ((priority ?? "").ToUpper())
        {
            case "LOW":    cls = "rc-dot--low";    break;
            case "HIGH":   cls = "rc-dot--high";   break;
            case "URGENT": cls = "rc-dot--urgent"; break;
        }
        return string.Format("<span class='rc-dot {0}'></span>{1}", cls, HttpUtility.HtmlEncode(priority ?? "Medium"));
    }

    private string FormatUGX(decimal amount) { return string.Format("{0:N0}", amount); }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        var dt = new DataTable();
        using (var conn = new MySqlConnection(ConnStr))
        using (var cmd  = new MySqlCommand(sql, conn))
        {
            if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
            conn.Open();
            using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
        }
        return dt;
    }

    private int     SafeInt(object v)     { int x; return v == null || v == DBNull.Value ? 0 : int.TryParse(v.ToString(), out x) ? x : 0; }
    private string  SafeStr(object v)     { return v == null || v == DBNull.Value ? "" : v.ToString().Trim(); }
    private decimal SafeDecimal(object v) { decimal x; return v == null || v == DBNull.Value ? 0 : decimal.TryParse(v.ToString(), out x) ? x : 0; }
}
