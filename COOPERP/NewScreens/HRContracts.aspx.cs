using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_HRContracts : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilterDropdowns();
            LoadFormDropdowns();
        }
        BindGrid();
        LoadStats();
        EmitEmployeeAutoFillScript();
    }

    #region Dropdowns

    private void LoadFilterDropdowns()
    {
        DataTable dtDepts = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlFilterDept.Items.Clear();
        ddlFilterDept.Items.Add(new ListItem("All Departments", ""));
        foreach (DataRow r in dtDepts.Rows)
            ddlFilterDept.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));

        DataTable dtJobs = ExecuteQuery("SELECT ID, jobname FROM hrm_jobs ORDER BY jobname");
        ddlFilterJob.Items.Clear();
        ddlFilterJob.Items.Add(new ListItem("All Positions", ""));
        foreach (DataRow r in dtJobs.Rows)
            ddlFilterJob.Items.Add(new ListItem(r["jobname"].ToString(), r["ID"].ToString()));
    }

    private void LoadFormDropdowns()
    {
        // Employees — include their last contract's job/dept for JS auto-fill
        DataTable dtEmp = ExecuteQuery(@"
            SELECT empID,
                   CONCAT(emp_name, ' [', IFNULL(EMP_CODE,''), ']') AS display
            FROM hrm_employee
            ORDER BY emp_name");
        ddlContractEmployee.Items.Clear();
        ddlContractEmployee.Items.Add(new ListItem("-- Select Employee --", ""));
        foreach (DataRow r in dtEmp.Rows)
            ddlContractEmployee.Items.Add(new ListItem(r["display"].ToString(), r["empID"].ToString()));

        DataTable dtJobs = ExecuteQuery("SELECT ID, jobname FROM hrm_jobs ORDER BY jobname");
        ddlContractJob.Items.Clear();
        ddlContractJob.Items.Add(new ListItem("-- Select Position --", ""));
        foreach (DataRow r in dtJobs.Rows)
            ddlContractJob.Items.Add(new ListItem(r["jobname"].ToString(), r["ID"].ToString()));

        DataTable dtDepts = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlContractDept.Items.Clear();
        ddlContractDept.Items.Add(new ListItem("-- Select Department --", ""));
        foreach (DataRow r in dtDepts.Rows)
            ddlContractDept.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));

        DataTable dtScales = ExecuteQuery("SELECT ID, CONCAT(scale_name, ' - ', FORMAT(basicpay,0)) AS display FROM hrm_payscales ORDER BY scale_name");
        ddlContractScale.Items.Clear();
        ddlContractScale.Items.Add(new ListItem("-- None (use fixed amount) --", ""));
        foreach (DataRow r in dtScales.Rows)
            ddlContractScale.Items.Add(new ListItem(r["display"].ToString(), r["ID"].ToString()));
    }

    /// <summary>
    /// Emits a JS object mapping empID -> { jobID, deptID } from their most recent contract,
    /// so the Add-Contract modal can auto-fill Position and Department when an employee is picked.
    /// </summary>
    private void EmitEmployeeAutoFillScript()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT e.empID,
                   COALESCE(
                       (SELECT c.jobID FROM hrm_emp_contracts c
                        WHERE c.empID = e.empID ORDER BY c.ID DESC LIMIT 1),
                       0) AS lastJobID,
                   COALESCE(
                       (SELECT c.departmentID FROM hrm_emp_contracts c
                        WHERE c.empID = e.empID ORDER BY c.ID DESC LIMIT 1),
                       0) AS lastDeptID
            FROM hrm_employee e");

        var sb = new StringBuilder("var employeeDefaults={");
        bool first = true;
        foreach (DataRow r in dt.Rows)
        {
            if (!first) sb.Append(",");
            first = false;
            sb.AppendFormat("'{0}':{{jobID:'{1}',deptID:'{2}'}}",
                r["empID"], r["lastJobID"], r["lastDeptID"]);
        }
        sb.Append("};");

        ScriptManager.RegisterStartupScript(this, GetType(), "empDefaults", sb.ToString(), true);
    }

    #endregion

    #region Stats

    private void LoadStats()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT
                COUNT(*) AS total_count,
                SUM(CASE WHEN contractStatus='VALID'    THEN 1 ELSE 0 END) AS valid_count,
                SUM(CASE WHEN contractStatus='EXPIRED'  THEN 1 ELSE 0 END) AS expired_count,
                SUM(CASE WHEN contractStatus='VALID'
                         AND contractEnd BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 90 DAY)
                         THEN 1 ELSE 0 END) AS expiring_count
            FROM hrm_emp_contracts");

        DataTable dtNoContract = ExecuteQuery(@"
            SELECT COUNT(*) AS cnt FROM hrm_employee e
            WHERE NOT EXISTS (SELECT 1 FROM hrm_emp_contracts c WHERE c.empID = e.empID)");

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litTotal.Text   = SafeInt(r["total_count"]).ToString();
            litValid.Text   = SafeInt(r["valid_count"]).ToString();
            litExpired.Text = SafeInt(r["expired_count"]).ToString();

            int expiring = SafeInt(r["expiring_count"]);
            litExpiring.Text         = expiring.ToString();
            pnlExpiryWarning.Visible = expiring > 0;
            litExpiryCount.Text      = expiring.ToString();
        }

        if (dtNoContract.Rows.Count > 0)
            litNoContract.Text = dtNoContract.Rows[0]["cnt"].ToString();
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int i; return int.TryParse(val.ToString(), out i) ? i : 0;
    }

    #endregion

    #region Grid Binding & Row Styling

    private void BindGrid()
    {
        string search = txtSearch.Text.Trim();
        string dept   = ddlFilterDept.SelectedValue;
        string status = ddlFilterStatus.SelectedValue;
        string job    = ddlFilterJob.SelectedValue;
        string type   = ddlFilterType.SelectedValue;

        var sql = new StringBuilder();
        sql.Append(@"
            SELECT c.ID AS contractID, c.contractStart, c.contractEnd, c.contractStatus,
                   c.contract_type, c.comments, c.fixedamount, c.payscale AS payscale_edit,
                   e.empID, e.EMP_CODE, e.emp_name,
                   j.jobname, d.dept_name, ps.scale_name,
                   IFNULL(ps.basicpay, c.fixedamount) AS basicpay,
                   DATEDIFF(c.contractEnd, CURDATE()) AS days_remaining
            FROM hrm_emp_contracts c
            JOIN hrm_employee e      ON e.empID    = c.empID
            LEFT JOIN hrm_jobs j         ON j.ID       = c.jobID
            LEFT JOIN hrm_departments d  ON d.ID       = c.departmentID
            LEFT JOIN hrm_payscales ps   ON ps.ID      = c.payscale
            WHERE 1=1");

        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(search))
        {
            sql.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search)");
            parms.Add(new MySqlParameter("@search", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(dept))
        {
            sql.Append(" AND c.departmentID = @dept");
            parms.Add(new MySqlParameter("@dept", dept));
        }
        if (!string.IsNullOrEmpty(status))
        {
            sql.Append(" AND c.contractStatus = @status");
            parms.Add(new MySqlParameter("@status", status));
        }
        if (!string.IsNullOrEmpty(job))
        {
            sql.Append(" AND c.jobID = @job");
            parms.Add(new MySqlParameter("@job", job));
        }
        if (!string.IsNullOrEmpty(type))
        {
            sql.Append(" AND c.contract_type = @ctype");
            parms.Add(new MySqlParameter("@ctype", type));
        }

        sql.Append(" ORDER BY c.contractEnd DESC");

        DataTable dt = ExecuteQuery(sql.ToString(), parms.ToArray());

        // Apply selected page size
        int pageSize;
        if (int.TryParse(ddlPageSize.SelectedValue, out pageSize) && pageSize > 0)
            gvContracts.SettingsPager.PageSize = pageSize;

        // Update record count displays
        string countText = dt.Rows.Count.ToString();
        litFilterCount.Text    = countText;
        litFilterCountTop.Text = countText;

        gvContracts.DataSource = dt;
        gvContracts.DataBind();
    }

    protected void gvContracts_HtmlRowCreated(object sender, ASPxGridViewTableRowEventArgs e)
    {
        if (e.RowType != GridViewRowType.Data) return;

        string status = (gvContracts.GetRowValues(e.VisibleIndex, "contractStatus") ?? "").ToString().ToUpper();
        object endObj = gvContracts.GetRowValues(e.VisibleIndex, "contractEnd");

        if (status == "EXPIRED" || status == "TERMINATED" || status == "RESIGNED")
        {
            e.Row.CssClass += " ct-row-expired";
        }
        else if (status == "VALID" && endObj != null && endObj != DBNull.Value)
        {
            DateTime endDate;
            if (DateTime.TryParse(endObj.ToString(), out endDate))
            {
                int days = (endDate - DateTime.Today).Days;
                e.Row.CssClass += days <= 90 ? " ct-row-expiring" : " ct-row-valid";
            }
        }
        else
        {
            e.Row.CssClass += " ct-row-other";
        }
    }

    #endregion

    #region Grid Events

    protected void gvContracts_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int contractID = Convert.ToInt32(e.Keys["contractID"]);

        object startVal  = e.NewValues["contractStart"];
        object endVal    = e.NewValues["contractEnd"];
        string status    = e.NewValues["contractStatus"] != null ? e.NewValues["contractStatus"].ToString() : "VALID";
        string ctype     = e.NewValues["contract_type"]  != null ? e.NewValues["contract_type"].ToString()  : "FULL TIME";
        string comments  = e.NewValues["comments"]       != null ? e.NewValues["comments"].ToString()       : "";
        object payscale  = e.NewValues["payscale_edit"];
        object fixedAmt  = e.NewValues["fixedamount"];

        ExecuteNonQuery(@"UPDATE hrm_emp_contracts SET
            contractStart=@start, contractEnd=@end, contractStatus=@status, contract_type=@ctype,
            comments=@comments, payscale=@scale, fixedamount=@fixed
            WHERE ID=@id",
            new MySqlParameter("@start",   startVal != null ? (object)Convert.ToDateTime(startVal) : DBNull.Value),
            new MySqlParameter("@end",     endVal   != null ? (object)Convert.ToDateTime(endVal)   : DBNull.Value),
            new MySqlParameter("@status",  status),
            new MySqlParameter("@ctype",   ctype),
            new MySqlParameter("@comments",comments),
            new MySqlParameter("@scale",   payscale != null && payscale.ToString() != "" ? (object)Convert.ToInt32(payscale)  : DBNull.Value),
            new MySqlParameter("@fixed",   fixedAmt != null && fixedAmt.ToString() != "" ? (object)Convert.ToDecimal(fixedAmt): DBNull.Value),
            new MySqlParameter("@id",      contractID));

        e.Cancel = true;
        gvContracts.CancelEdit();
        BindGrid();
        LoadStats();
    }

    protected void gvContracts_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int contractID = Convert.ToInt32(e.Keys["contractID"]);
        ExecuteNonQuery("DELETE FROM hrm_emp_contracts WHERE ID=@id",
            new MySqlParameter("@id", contractID));

        e.Cancel = true;
        gvContracts.CancelEdit();
        BindGrid();
        LoadStats();
    }

    #endregion

    #region Add Contract

    protected void btnAddContract_Click(object sender, EventArgs e)
    {
        string empID  = ddlContractEmployee.SelectedValue;
        string jobID  = ddlContractJob.SelectedValue;
        string deptID = ddlContractDept.SelectedValue;

        if (string.IsNullOrEmpty(empID) || empID == "")
        {
            ShowResult("addContractResult", "addContractModal", "Please select an employee.", false);
            return;
        }
        if (string.IsNullOrEmpty(jobID))
        {
            ShowResult("addContractResult", "addContractModal", "Please select a position.", false);
            return;
        }
        if (string.IsNullOrEmpty(deptID))
        {
            ShowResult("addContractResult", "addContractModal", "Please select a department.", false);
            return;
        }

        // Prevent more than one contract per employee
        DataTable existingCheck = ExecuteQuery(
            "SELECT COUNT(*) AS cnt FROM hrm_emp_contracts WHERE empID=@eid AND contractStatus='VALID'",
            new MySqlParameter("@eid", empID));
        if (SafeInt(existingCheck.Rows[0]["cnt"]) > 0)
        {
            ShowResult("addContractResult", "addContractModal",
                "This employee already has an active contract. Use 'Renew Contract' on the existing record to extend it.", false);
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtContractStart.Text, out startDate) || !DateTime.TryParse(txtContractEnd.Text, out endDate))
        {
            ShowResult("addContractResult", "addContractModal", "Please provide valid start and end dates.", false);
            return;
        }
        if (endDate <= startDate)
        {
            ShowResult("addContractResult", "addContractModal", "End date must be after start date.", false);
            return;
        }

        string  ctype     = rbPartTime.Checked ? "PART TIME" : "FULL TIME";
        string  scaleVal  = ddlContractScale.SelectedValue;
        decimal fixedAmt;
        if (!decimal.TryParse(txtContractFixed.Text, out fixedAmt)) fixedAmt = 0;

        ExecuteNonQuery(@"INSERT INTO hrm_emp_contracts
            (empID, contractStart, contractEnd, jobID, departmentID, payscale, fixedamount, comments, contractStatus, contract_type)
            VALUES (@eid,@start,@end,@job,@dept,@scale,@fixed,@comments,'VALID',@ctype)",
            new MySqlParameter("@eid",      empID),
            new MySqlParameter("@start",    startDate),
            new MySqlParameter("@end",      endDate),
            new MySqlParameter("@job",      jobID),
            new MySqlParameter("@dept",     deptID),
            new MySqlParameter("@scale",    !string.IsNullOrEmpty(scaleVal) ? (object)Convert.ToInt32(scaleVal) : DBNull.Value),
            new MySqlParameter("@fixed",    fixedAmt),
            new MySqlParameter("@comments", txtContractComments.Text.Trim()),
            new MySqlParameter("@ctype",    ctype));

        // Reset form
        txtContractStart.Text    = "";
        txtContractEnd.Text      = "";
        txtContractComments.Text = "";
        txtContractFixed.Text    = "0";
        rbFullTime.Checked       = true;
        rbPartTime.Checked       = false;

        BindGrid();
        LoadStats();

        ScriptManager.RegisterStartupScript(this, GetType(), "closeAdd",
            "document.getElementById('addContractModal').style.display='none';", true);
    }

    #endregion

    #region Renew Contract

    protected void btnRenewContract_Click(object sender, EventArgs e)
    {
        string contractIDStr = hdnRenewContractID.Value;
        string empID         = hdnRenewEmpID.Value;

        if (string.IsNullOrEmpty(contractIDStr) || string.IsNullOrEmpty(empID))
        {
            ShowResult("renewResult", "renewModal", "Invalid contract reference.", false);
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtRenewStart.Text, out startDate) || !DateTime.TryParse(txtRenewEnd.Text, out endDate))
        {
            ShowResult("renewResult", "renewModal", "Please provide valid start and end dates.", false);
            return;
        }
        if (endDate <= startDate)
        {
            ShowResult("renewResult", "renewModal", "End date must be after start date.", false);
            return;
        }

        string ctype = ddlRenewType.SelectedValue;
        if (string.IsNullOrEmpty(ctype)) ctype = "FULL TIME";

        // Copy job/dept/scale from original
        DataTable orig = ExecuteQuery(
            "SELECT jobID, departmentID, payscale, fixedamount FROM hrm_emp_contracts WHERE ID=@id",
            new MySqlParameter("@id", contractIDStr));
        if (orig.Rows.Count == 0)
        {
            ShowResult("renewResult", "renewModal", "Original contract not found.", false);
            return;
        }
        DataRow oc = orig.Rows[0];

        // Mark old contract expired
        ExecuteNonQuery("UPDATE hrm_emp_contracts SET contractStatus='EXPIRED' WHERE ID=@id",
            new MySqlParameter("@id", contractIDStr));

        // Insert renewal
        ExecuteNonQuery(@"INSERT INTO hrm_emp_contracts
            (empID, contractStart, contractEnd, jobID, departmentID, payscale, fixedamount, comments, contractStatus, contract_type)
            VALUES (@eid,@start,@end,@job,@dept,@scale,@fixed,@comments,'VALID',@ctype)",
            new MySqlParameter("@eid",      empID),
            new MySqlParameter("@start",    startDate),
            new MySqlParameter("@end",      endDate),
            new MySqlParameter("@job",      oc["jobID"]),
            new MySqlParameter("@dept",     oc["departmentID"]),
            new MySqlParameter("@scale",    oc["payscale"]    != DBNull.Value ? oc["payscale"]    : DBNull.Value),
            new MySqlParameter("@fixed",    oc["fixedamount"] != DBNull.Value ? oc["fixedamount"] : (object)0m),
            new MySqlParameter("@comments", txtRenewComments.Text.Trim()),
            new MySqlParameter("@ctype",    ctype));

        BindGrid();
        LoadStats();

        ScriptManager.RegisterStartupScript(this, GetType(), "closeRenew",
            "document.getElementById('renewModal').style.display='none';", true);
    }

    #endregion

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

        hdnBatchIDs.Value = "";
        BindGrid();
        LoadStats();
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

        hdnBatchIDs.Value = "";
        BindGrid();
        LoadStats();
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

        hdnBatchIDs.Value    = "";
        hdnBatchStatus.Value = "";
        BindGrid();
        LoadStats();
    }

    private string[] GetBatchIDs()
    {
        string raw = hdnBatchIDs.Value ?? "";
        if (string.IsNullOrEmpty(raw)) return new string[0];
        return raw.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);
    }

    #endregion

    #region Filter & Pager Events

    protected void ddlFilter_Changed(object sender, EventArgs e) { BindGrid(); }
    protected void btnSearch_Click(object sender, EventArgs e)    { BindGrid(); }

    protected void ddlPageSize_Changed(object sender, EventArgs e)
    {
        int size;
        if (int.TryParse(ddlPageSize.SelectedValue, out size) && size > 0)
            gvContracts.SettingsPager.PageSize = size;
        BindGrid();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text                = "";
        ddlFilterDept.SelectedIndex   = 0;
        ddlFilterStatus.SelectedIndex = 0;
        ddlFilterJob.SelectedIndex    = 0;
        ddlFilterType.SelectedIndex   = 0;
        // keep ddlPageSize as-is (user preference)
        BindGrid();
    }

    #endregion

    #region Template Helpers

    protected string GetContractTypeBadge(object type)
    {
        string t   = (type != null && type != DBNull.Value) ? type.ToString() : "FULL TIME";
        string css = t == "PART TIME" ? "ct-type--part" : "ct-type--full";
        return string.Format("<span class='ct-type {0}'>{1}</span>", css, HttpUtility.HtmlEncode(t));
    }

    protected string GetStatusBadge(object status)
    {
        if (status == null || status == DBNull.Value) return "<span class='hr-badge hr-badge--none'>NONE</span>";
        string s   = status.ToString().ToUpper();
        string css = s == "VALID"      ? "hr-badge--valid"
                   : s == "EXPIRED"    ? "hr-badge--expired"
                   : s == "TERMINATED" ? "hr-badge--terminated"
                   : s == "RESIGNED"   ? "hr-badge--resigned"
                   : "hr-badge--none";
        return string.Format("<span class='hr-badge {0}'>{1}</span>", css, HttpUtility.HtmlEncode(s));
    }

    protected string GetDaysRemainingHtml(object endDateObj, object statusObj)
    {
        string status = (statusObj != null && statusObj != DBNull.Value) ? statusObj.ToString().ToUpper() : "";
        if (status != "VALID") return "<span class='ct-days--na'>-</span>";
        if (endDateObj == null || endDateObj == DBNull.Value) return "<span class='ct-days--na'>-</span>";

        DateTime endDate;
        if (!DateTime.TryParse(endDateObj.ToString(), out endDate)) return "<span class='ct-days--na'>-</span>";

        int days = (endDate - DateTime.Today).Days;
        if (days <= 0)
            return "<span class='ct-days ct-days--over'>OVERDUE</span>";
        if (days <= 30)
            return string.Format("<span class='ct-days ct-days--urgent'>{0}d</span>", days);
        if (days <= 90)
            return string.Format("<span class='ct-days ct-days--warn'>{0}d</span>", days);
        return string.Format("<span class='ct-days ct-days--ok'>{0}d</span>", days);
    }

    protected string FormatCurrency(object val)
    {
        if (val == null || val == DBNull.Value) return "-";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d)) return d.ToString("N0");
        return val.ToString();
    }

    protected string GetActionButtonsHtml(object contractID, object empNameObj, object statusObj, object empIDObj, object contractTypeObj)
    {
        string id           = contractID.ToString();
        string empID        = empIDObj        != null ? empIDObj.ToString()        : "";
        string empName      = (empNameObj     != null ? empNameObj.ToString()      : "").Replace("'", "\\'");
        string status       = (statusObj      != null ? statusObj.ToString()       : "").ToUpper();
        string contractType = (contractTypeObj != null ? contractTypeObj.ToString() : "FULL TIME").Replace("'", "\\'");

        string dotsSvg  = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='5' r='1'/><circle cx='12' cy='12' r='1'/><circle cx='12' cy='19' r='1'/></svg>";
        string editSvg  = "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M12 20h9'/><path d='M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z'/></svg>";
        string delSvg   = "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='3 6 5 6 21 6'/><path d='M19 6l-1 14H6L5 6'/><path d='M10 11v6'/><path d='M14 11v6'/><path d='M9 6V4h6v2'/></svg>";
        string renewSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='23 4 23 10 17 10'/><polyline points='1 20 1 14 7 14'/><path d='M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15'/></svg>";

        string renewItem = "";
        if (status == "VALID" || status == "EXPIRED")
        {
            renewItem =
                "<li class='cd-action-popover__item'>" +
                "<button type='button' class='cd-action-popover__btn cd-action-popover__btn--success' " +
                "onclick='openRenewModal(" + id + ",\"" + empID + "\",\"" + empName + "\",\"\",\"" + contractType + "\")'>" +
                renewSvg + " Renew Contract</button></li>" +
                "<li class='cd-action-popover__divider'></li>";
        }

        return
            "<div class='cd-action-wrapper'>" +
            "<button type='button' class='cd-action-trigger' onclick='toggleActionPopover(this,event)'>" + dotsSvg + "</button>" +
            "<div class='cd-action-popover'><ul class='cd-action-popover__menu'>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn' onclick='gridEdit(\"gvContracts\"," + id + ")'>" + editSvg + " Edit</button></li>" +
            renewItem +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--danger' onclick='gridDelete(\"gvContracts\"," + id + ")'>" + delSvg + " Delete</button></li>" +
            "</ul></div></div>";
    }

    #endregion

    #region Helpers

    private void ShowResult(string resultId, string modalId, string message, bool success)
    {
        string css = success ? "hr-result hr-result--ok" : "hr-result hr-result--err";
        ScriptManager.RegisterStartupScript(this, GetType(), "res_" + resultId,
            string.Format(
                "(function(){{var r=document.getElementById('{0}');r.className='{1}';r.innerHTML='{2}';document.getElementById('{3}').style.display='flex';}})()",
                resultId, css, HttpUtility.JavaScriptStringEncode(message), modalId),
            true);
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

    #endregion
}
