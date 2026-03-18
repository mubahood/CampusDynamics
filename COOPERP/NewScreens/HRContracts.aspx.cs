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
        // Employees
        DataTable dtEmp = ExecuteQuery("SELECT empID, CONCAT(emp_name, ' [', IFNULL(EMP_CODE,''), ']') AS display FROM hrm_employee ORDER BY emp_name");
        ddlContractEmployee.Items.Clear();
        ddlContractEmployee.Items.Add(new ListItem("-- Select Employee --", ""));
        foreach (DataRow r in dtEmp.Rows)
            ddlContractEmployee.Items.Add(new ListItem(r["display"].ToString(), r["empID"].ToString()));

        // Jobs
        DataTable dtJobs = ExecuteQuery("SELECT ID, jobname FROM hrm_jobs ORDER BY jobname");
        ddlContractJob.Items.Clear();
        ddlContractJob.Items.Add(new ListItem("-- Select Position --", ""));
        foreach (DataRow r in dtJobs.Rows)
            ddlContractJob.Items.Add(new ListItem(r["jobname"].ToString(), r["ID"].ToString()));

        // Departments
        DataTable dtDepts = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlContractDept.Items.Clear();
        ddlContractDept.Items.Add(new ListItem("-- Select Department --", ""));
        foreach (DataRow r in dtDepts.Rows)
            ddlContractDept.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));

        // Pay Scales
        DataTable dtScales = ExecuteQuery("SELECT ID, CONCAT(scale_name, ' - ', FORMAT(basicpay,0)) AS display FROM hrm_payscales ORDER BY scale_name");
        ddlContractScale.Items.Clear();
        ddlContractScale.Items.Add(new ListItem("-- None (use fixed amount) --", ""));
        foreach (DataRow r in dtScales.Rows)
            ddlContractScale.Items.Add(new ListItem(r["display"].ToString(), r["ID"].ToString()));
    }

    #endregion

    #region Stats

    private void LoadStats()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT 
                SUM(CASE WHEN latest.contractStatus='VALID' THEN 1 ELSE 0 END) AS valid_count,
                SUM(CASE WHEN latest.contractStatus='EXPIRED' THEN 1 ELSE 0 END) AS expired_count,
                SUM(CASE WHEN latest.contractStatus='VALID' AND latest.contractEnd BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 90 DAY) THEN 1 ELSE 0 END) AS expiring_count
            FROM (
                SELECT c.contractStatus, c.contractEnd
                FROM hrm_emp_contracts c
                WHERE c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = c.empID)
            ) latest");

        DataTable dtNoContract = ExecuteQuery(@"
            SELECT COUNT(*) AS cnt FROM hrm_employee e
            WHERE NOT EXISTS (SELECT 1 FROM hrm_emp_contracts c WHERE c.empID = e.empID)");

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litValid.Text = (r["valid_count"] != DBNull.Value ? r["valid_count"] : 0).ToString();
            litExpired.Text = (r["expired_count"] != DBNull.Value ? r["expired_count"] : 0).ToString();

            int expiring = r["expiring_count"] != DBNull.Value ? Convert.ToInt32(r["expiring_count"]) : 0;
            litExpiring.Text = expiring.ToString();

            if (expiring > 0)
            {
                pnlExpiryWarning.Visible = true;
                litExpiryCount.Text = expiring.ToString();
            }
            else
            {
                pnlExpiryWarning.Visible = false;
            }
        }

        if (dtNoContract.Rows.Count > 0)
            litNoContract.Text = dtNoContract.Rows[0]["cnt"].ToString();
    }

    #endregion

    #region Grid Binding

    private void BindGrid()
    {
        string search = txtSearch.Text.Trim();
        string dept = ddlFilterDept.SelectedValue;
        string status = ddlFilterStatus.SelectedValue;
        string job = ddlFilterJob.SelectedValue;

        StringBuilder sql = new StringBuilder();
        sql.Append(@"SELECT c.ID AS contractID, c.contractStart, c.contractEnd, c.contractStatus,
            c.comments, c.fixedamount, c.payscale AS payscale_edit,
            e.empID, e.EMP_CODE, e.emp_name,
            j.jobname, d.dept_name, ps.scale_name,
            IFNULL(ps.basicpay, c.fixedamount) AS basicpay,
            DATEDIFF(c.contractEnd, CURDATE()) AS days_remaining
        FROM hrm_emp_contracts c
        JOIN hrm_employee e ON e.empID = c.empID
        LEFT JOIN hrm_jobs j ON j.ID = c.jobID
        LEFT JOIN hrm_departments d ON d.ID = c.departmentID
        LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
        WHERE 1=1 ");

        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(search))
        {
            sql.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search) ");
            parms.Add(new MySqlParameter("@search", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(dept))
        {
            sql.Append(" AND c.departmentID = @dept ");
            parms.Add(new MySqlParameter("@dept", dept));
        }
        if (!string.IsNullOrEmpty(status))
        {
            sql.Append(" AND c.contractStatus = @status ");
            parms.Add(new MySqlParameter("@status", status));
        }
        if (!string.IsNullOrEmpty(job))
        {
            sql.Append(" AND c.jobID = @job ");
            parms.Add(new MySqlParameter("@job", job));
        }

        sql.Append(" ORDER BY c.contractEnd DESC ");

        DataTable dt = ExecuteQuery(sql.ToString(), parms.ToArray());
        gvContracts.DataSource = dt;
        gvContracts.DataBind();
    }

    #endregion

    #region Grid Events

    protected void gvContracts_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int contractID = Convert.ToInt32(e.Keys["contractID"]);

        object startVal = e.NewValues["contractStart"];
        object endVal = e.NewValues["contractEnd"];
        string status = e.NewValues["contractStatus"] != null ? e.NewValues["contractStatus"].ToString() : "VALID";
        string comments = e.NewValues["comments"] != null ? e.NewValues["comments"].ToString() : "";
        object payscale = e.NewValues["payscale_edit"];
        object fixedAmt = e.NewValues["fixedamount"];

        ExecuteNonQuery(@"UPDATE hrm_emp_contracts SET 
            contractStart = @start, contractEnd = @end, contractStatus = @status,
            comments = @comments, payscale = @scale, fixedamount = @fixed
            WHERE ID = @id",
            new MySqlParameter("@start", startVal != null ? (object)Convert.ToDateTime(startVal) : DBNull.Value),
            new MySqlParameter("@end", endVal != null ? (object)Convert.ToDateTime(endVal) : DBNull.Value),
            new MySqlParameter("@status", status),
            new MySqlParameter("@comments", comments),
            new MySqlParameter("@scale", payscale != null && payscale.ToString() != "" ? (object)Convert.ToInt32(payscale) : DBNull.Value),
            new MySqlParameter("@fixed", fixedAmt != null && fixedAmt.ToString() != "" ? (object)Convert.ToDecimal(fixedAmt) : DBNull.Value),
            new MySqlParameter("@id", contractID));

        e.Cancel = true;
        gvContracts.CancelEdit();
        BindGrid();
        LoadStats();
    }

    protected void gvContracts_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int contractID = Convert.ToInt32(e.Keys["contractID"]);
        ExecuteNonQuery("DELETE FROM hrm_emp_contracts WHERE ID = @id", new MySqlParameter("@id", contractID));

        e.Cancel = true;
        gvContracts.CancelEdit();
        BindGrid();
        LoadStats();
    }

    #endregion

    #region Add Contract

    protected void btnAddContract_Click(object sender, EventArgs e)
    {
        string empID = ddlContractEmployee.SelectedValue;
        string jobID = ddlContractJob.SelectedValue;
        string deptID = ddlContractDept.SelectedValue;

        if (string.IsNullOrEmpty(empID) || string.IsNullOrEmpty(jobID) || string.IsNullOrEmpty(deptID))
        {
            ShowModalError("addContractModal", "addContractResult", "Employee, Position, and Department are required.");
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtContractStart.Text, out startDate) || !DateTime.TryParse(txtContractEnd.Text, out endDate))
        {
            ShowModalError("addContractModal", "addContractResult", "Please provide valid start and end dates.");
            return;
        }

        string scaleVal = ddlContractScale.SelectedValue;
        decimal fixedAmount;
        if (!decimal.TryParse(txtContractFixed.Text, out fixedAmount)) fixedAmount = 0;

        ExecuteNonQuery(@"INSERT INTO hrm_emp_contracts 
            (empID, contractStart, contractEnd, jobID, departmentID, payscale, fixedamount, comments, contractStatus)
            VALUES (@eid, @start, @end, @job, @dept, @scale, @fixed, @comments, 'VALID')",
            new MySqlParameter("@eid", empID),
            new MySqlParameter("@start", startDate),
            new MySqlParameter("@end", endDate),
            new MySqlParameter("@job", jobID),
            new MySqlParameter("@dept", deptID),
            new MySqlParameter("@scale", !string.IsNullOrEmpty(scaleVal) ? (object)Convert.ToInt32(scaleVal) : DBNull.Value),
            new MySqlParameter("@fixed", fixedAmount),
            new MySqlParameter("@comments", txtContractComments.Text.Trim()));

        txtContractStart.Text = "";
        txtContractEnd.Text = "";
        txtContractComments.Text = "";
        txtContractFixed.Text = "0";

        BindGrid();
        LoadStats();
    }

    #endregion

    #region Filter Events

    protected void ddlFilter_Changed(object sender, EventArgs e) { BindGrid(); }
    protected void btnSearch_Click(object sender, EventArgs e) { BindGrid(); }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlFilterDept.SelectedIndex = 0;
        ddlFilterStatus.SelectedIndex = 0;
        ddlFilterJob.SelectedIndex = 0;
        BindGrid();
    }

    #endregion

    #region Template Helpers

    protected string GetStatusBadge(object status)
    {
        if (status == null || status == DBNull.Value) return "<span class='hr-badge hr-badge--none'>NONE</span>";
        string s = status.ToString().ToUpper();
        string css = "hr-badge--none";
        if (s == "VALID") css = "hr-badge--valid";
        else if (s == "EXPIRED") css = "hr-badge--expired";
        else if (s == "TERMINATED") css = "hr-badge--terminated";
        else if (s == "RESIGNED") css = "hr-badge--resigned";
        return string.Format("<span class='hr-badge {0}'>{1}</span>", css, HttpUtility.HtmlEncode(s));
    }

    protected string GetDaysRemainingHtml(object endDateObj, object statusObj)
    {
        string status = (statusObj != null && statusObj != DBNull.Value) ? statusObj.ToString().ToUpper() : "";
        if (status != "VALID") return "<span style='color:#888;font-size:10px;'>—</span>";

        if (endDateObj == null || endDateObj == DBNull.Value) return "—";

        DateTime endDate;
        if (!DateTime.TryParse(endDateObj.ToString(), out endDate)) return "—";

        int days = (endDate - DateTime.Today).Days;
        string color = days <= 0 ? "#dc3545" : days <= 90 ? "#ffc107" : "#28a745";
        string text = days <= 0 ? "OVERDUE" : days.ToString() + " days";

        return string.Format("<span style='font-weight:600;color:{0};font-size:11px;'>{1}</span>", color, text);
    }

    protected string FormatCurrency(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d)) return d.ToString("N0");
        return val.ToString();
    }

    #endregion

    #region Helpers

    private void ShowModalError(string modalId, string resultId, string message)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "modalErr",
            "document.getElementById('" + resultId + "').innerHTML='<span style=\"color:red;\">" +
            HttpUtility.JavaScriptStringEncode(message) + "</span>';document.getElementById('" + modalId + "').style.display='flex';", true);
    }

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
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
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

    #endregion
}
