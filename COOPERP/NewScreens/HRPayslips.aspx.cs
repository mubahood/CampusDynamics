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

public partial class COOPERP_NewScreens_HRPayslips : System.Web.UI.Page
{
    // =====================================================================
    // SECTION 1: Infrastructure
    // =====================================================================

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] prms)
    {
        var dt = new DataTable();
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    if (prms != null) cmd.Parameters.AddRange(prms);
                    using (var da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Database error: " + ex.Message, "danger");
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] prms)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    if (prms != null) cmd.Parameters.AddRange(prms);
                    return cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Database error: " + ex.Message, "danger");
            return 0;
        }
    }

    private int ExecuteNonQueryWithConn(MySqlConnection conn, string sql, params MySqlParameter[] prms)
    {
        try
        {
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (prms != null) cmd.Parameters.AddRange(prms);
                return cmd.ExecuteNonQuery();
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Row error: " + ex.Message, "warning");
            return 0;
        }
    }

    private decimal SafeDecimal(object val)
    {
        if (val == null || val == DBNull.Value) return 0m;
        decimal result;
        return decimal.TryParse(val.ToString(), out result) ? result : 0m;
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        return int.TryParse(val.ToString(), out result) ? result : 0;
    }

    private string GetCurrentUser()
    {
        if (Session["username"] != null) return Session["username"].ToString();
        if (Session["usernm"] != null) return Session["usernm"].ToString();
        return "SYSTEM";
    }

    private void ShowAlert(string message, string type)
    {
        litPageAlert.Text = string.Format(
            "<div class=\"hr-alert hr-alert--{0}\">{1}</div>", type, message);
    }

    private void EnsurePayslipsTableExists()
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    CREATE TABLE IF NOT EXISTS hrm_payslips (
                        ID INT NOT NULL AUTO_INCREMENT,
                        payroll_id INT NOT NULL,
                        empID INT NOT NULL,
                        payroll_year INT NOT NULL,
                        payroll_month INT NOT NULL,
                        payroll_month_name ENUM('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
                            'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER') NOT NULL,
                        basic_pay DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        gross_salary DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        total_allowances DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        allowance_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        allowance_details TEXT NULL,
                        total_deductions DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        deduction_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        deduction_details TEXT NULL,
                        paye DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        nssf DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        kabaka_contribution DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        local_tax DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        net_salary DECIMAL(15,2) NOT NULL DEFAULT 0.00,
                        status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
                        date_generated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        approved_by VARCHAR(100) NULL,
                        date_approved DATETIME NULL,
                        rejection_reason TEXT NULL,
                        PRIMARY KEY (ID),
                        UNIQUE KEY uq_payslip_payroll_emp (payroll_id, empID),
                        INDEX idx_ps_payroll (payroll_id),
                        INDEX idx_ps_emp (empID),
                        INDEX idx_ps_status (status),
                        INDEX idx_ps_period (payroll_year, payroll_month)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", conn))
                    cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    // =====================================================================
    // SECTION 2: Page_Load
    // =====================================================================

    protected void Page_Load(object sender, EventArgs e)
    {
        EnsurePayslipsTableExists();
        if (!IsPostBack)
        {
            LoadFilterDropdowns();

            // Pre-filter by payroll_id from QueryString
            string qsPayrollId = Request.QueryString["payroll_id"];
            if (!string.IsNullOrEmpty(qsPayrollId))
            {
                ListItem li = ddlFilterPayroll.Items.FindByValue(qsPayrollId);
                if (li != null) li.Selected = true;
            }
        }

        BindGrid();
        LoadStats();
    }

    // =====================================================================
    // SECTION 3: LoadFilterDropdowns
    // =====================================================================

    private void LoadFilterDropdowns()
    {
        // Payroll dropdown
        ddlFilterPayroll.Items.Clear();
        ddlFilterPayroll.Items.Add(new ListItem("All Payrolls", ""));
        DataTable dtPay = ExecuteQuery(
            "SELECT ID, payroll_title FROM hrm_payroll ORDER BY payroll_year DESC, payroll_month DESC");
        foreach (DataRow r in dtPay.Rows)
            ddlFilterPayroll.Items.Add(new ListItem(r["payroll_title"].ToString(), r["ID"].ToString()));

        // Employee dropdown
        ddlFilterEmployee.Items.Clear();
        ddlFilterEmployee.Items.Add(new ListItem("All Employees", ""));
        DataTable dtEmp = ExecuteQuery(
            "SELECT DISTINCT e.empID, CONCAT(e.emp_name,' [',IFNULL(e.EMP_CODE,''),']') AS display " +
            "FROM hrm_payslips ps " +
            "JOIN hrm_employee e ON e.empID = ps.empID " +
            "ORDER BY e.emp_name");
        foreach (DataRow r in dtEmp.Rows)
            ddlFilterEmployee.Items.Add(new ListItem(r["display"].ToString(), r["empID"].ToString()));
    }

    // =====================================================================
    // SECTION 4: BindGrid
    // =====================================================================

    private void BindGrid()
    {
        try
        {
            var sb = new StringBuilder();
            var prms = new List<MySqlParameter>();

            sb.Append(
                "SELECT ps.ID, ps.payroll_id, p.payroll_title, ps.empID, " +
                "e.EMP_CODE, e.emp_name, " +
                "ps.payroll_month_name, ps.payroll_year, " +
                "ps.basic_pay, ps.total_allowances, ps.total_deductions, " +
                "ps.paye, ps.nssf, ps.kabaka_contribution, ps.local_tax, " +
                "ps.net_salary, ps.status, ps.date_generated, " +
                "ps.approved_by, ps.allowance_details, ps.deduction_details " +
                "FROM hrm_payslips ps " +
                "JOIN hrm_payroll p ON p.ID = ps.payroll_id " +
                "JOIN hrm_employee e ON e.empID = ps.empID " +
                "WHERE 1=1");

            // Payroll filter
            if (!string.IsNullOrEmpty(ddlFilterPayroll.SelectedValue))
            {
                sb.Append(" AND ps.payroll_id = @payroll");
                prms.Add(new MySqlParameter("@payroll", ddlFilterPayroll.SelectedValue));
            }

            // Employee filter
            if (!string.IsNullOrEmpty(ddlFilterEmployee.SelectedValue))
            {
                sb.Append(" AND ps.empID = @emp");
                prms.Add(new MySqlParameter("@emp", ddlFilterEmployee.SelectedValue));
            }

            // Status filter
            if (!string.IsNullOrEmpty(ddlFilterStatus.SelectedValue))
            {
                sb.Append(" AND ps.status = @status");
                prms.Add(new MySqlParameter("@status", ddlFilterStatus.SelectedValue));
            }

            // Month filter
            if (!string.IsNullOrEmpty(ddlFilterMonth.SelectedValue))
            {
                sb.Append(" AND ps.payroll_month_name = @month");
                prms.Add(new MySqlParameter("@month", ddlFilterMonth.SelectedValue));
            }

            // Year filter
            if (!string.IsNullOrEmpty(txtFilterYear.Text.Trim()))
            {
                sb.Append(" AND ps.payroll_year = @year");
                prms.Add(new MySqlParameter("@year", txtFilterYear.Text.Trim()));
            }

            // Search filter
            if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
            {
                sb.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search)");
                prms.Add(new MySqlParameter("@search", "%" + txtSearch.Text.Trim() + "%"));
            }

            sb.Append(" ORDER BY ps.payroll_year DESC, ps.payroll_month DESC, e.emp_name");

            DataTable dt = ExecuteQuery(sb.ToString(), prms.ToArray());

            // Page size
            int pageSize = 25;
            int.TryParse(ddlPageSize.SelectedValue, out pageSize);
            gvPayslips.SettingsPager.PageSize = pageSize;

            gvPayslips.DataSource = dt;
            gvPayslips.DataBind();

            int count = dt != null ? dt.Rows.Count : 0;
            litFilterCount.Text = count.ToString();
            litFilterCountTop.Text = count.ToString();
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading payslips: " + ex.Message, "danger");
        }
    }

    // =====================================================================
    // SECTION 5: LoadStats
    // =====================================================================

    private void LoadStats()
    {
        try
        {
            var sb = new StringBuilder();
            var prms = new List<MySqlParameter>();

            bool needsEmpJoin = !string.IsNullOrEmpty(ddlFilterEmployee.SelectedValue)
                             || !string.IsNullOrEmpty(txtSearch.Text.Trim());

            sb.Append(
                "SELECT " +
                "COUNT(*) AS total, " +
                "SUM(CASE WHEN ps.status='PENDING' THEN 1 ELSE 0 END) AS pending, " +
                "SUM(CASE WHEN ps.status='APPROVED' THEN 1 ELSE 0 END) AS approved, " +
                "SUM(CASE WHEN ps.status='REJECTED' THEN 1 ELSE 0 END) AS rejected " +
                "FROM hrm_payslips ps ");

            if (needsEmpJoin)
                sb.Append("JOIN hrm_employee e ON e.empID = ps.empID ");

            sb.Append("WHERE 1=1");

            if (!string.IsNullOrEmpty(ddlFilterPayroll.SelectedValue))
            {
                sb.Append(" AND ps.payroll_id = @payroll");
                prms.Add(new MySqlParameter("@payroll", ddlFilterPayroll.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlFilterEmployee.SelectedValue))
            {
                sb.Append(" AND ps.empID = @emp");
                prms.Add(new MySqlParameter("@emp", ddlFilterEmployee.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlFilterStatus.SelectedValue))
            {
                sb.Append(" AND ps.status = @status");
                prms.Add(new MySqlParameter("@status", ddlFilterStatus.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlFilterMonth.SelectedValue))
            {
                sb.Append(" AND ps.payroll_month_name = @month");
                prms.Add(new MySqlParameter("@month", ddlFilterMonth.SelectedValue));
            }

            if (!string.IsNullOrEmpty(txtFilterYear.Text.Trim()))
            {
                sb.Append(" AND ps.payroll_year = @year");
                prms.Add(new MySqlParameter("@year", txtFilterYear.Text.Trim()));
            }

            if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
            {
                sb.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search)");
                prms.Add(new MySqlParameter("@search", "%" + txtSearch.Text.Trim() + "%"));
            }

            DataTable dt = ExecuteQuery(sb.ToString(), prms.ToArray());

            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                litTotalPayslips.Text = SafeInt(r["total"]).ToString("N0");
                litPendingCount.Text = SafeInt(r["pending"]).ToString("N0");
                litApprovedCount.Text = SafeInt(r["approved"]).ToString("N0");
                litRejectedCount.Text = SafeInt(r["rejected"]).ToString("N0");
            }
            else
            {
                litTotalPayslips.Text = "0";
                litPendingCount.Text = "0";
                litApprovedCount.Text = "0";
                litRejectedCount.Text = "0";
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading stats: " + ex.Message, "warning");
        }
    }

    // =====================================================================
    // SECTION 6: btnExecuteSlipAction_Click - handles APPROVE from popover
    // =====================================================================

    protected void btnExecuteSlipAction_Click(object sender, EventArgs e)
    {
        int id = SafeInt(hdnSlipActionID.Value);
        string action = (hdnSlipActionType.Value ?? "").ToUpper().Trim();

        if (id > 0 && action == "APPROVE")
        {
            ApprovePayslip(id);
        }

        BindGrid();
        LoadStats();
    }

    // =====================================================================
    // SECTION 7: btnConfirmReject_Click
    // =====================================================================

    protected void btnConfirmReject_Click(object sender, EventArgs e)
    {
        int id = SafeInt(hdnSlipActionID.Value);
        string reason = txtRejectReason.Text.Trim();

        if (id > 0)
        {
            RejectPayslip(id, reason);
        }

        ShowModalScript("closeRejectModal");
        txtRejectReason.Text = "";
        BindGrid();
        LoadStats();
    }

    // =====================================================================
    // SECTION 8: ApprovePayslip
    // =====================================================================

    private void ApprovePayslip(int id)
    {
        try
        {
            string sql =
                "UPDATE hrm_payslips " +
                "SET status='APPROVED', approved_by=@user, date_approved=NOW(), rejection_reason=NULL " +
                "WHERE ID=@id AND status != 'APPROVED'";

            int rows = ExecuteNonQuery(sql,
                new MySqlParameter("@user", GetCurrentUser()),
                new MySqlParameter("@id", id));

            if (rows > 0)
                ShowAlert("Payslip approved successfully.", "success");
            else
                ShowAlert("Payslip could not be approved (already approved or not found).", "warning");
        }
        catch (Exception ex)
        {
            ShowAlert("Error approving payslip: " + ex.Message, "danger");
        }
    }

    // =====================================================================
    // SECTION 9: RejectPayslip
    // =====================================================================

    private void RejectPayslip(int id, string reason)
    {
        try
        {
            string sql =
                "UPDATE hrm_payslips " +
                "SET status='REJECTED', rejection_reason=@reason, approved_by=NULL, date_approved=NULL " +
                "WHERE ID=@id";

            int rows = ExecuteNonQuery(sql,
                new MySqlParameter("@reason", reason),
                new MySqlParameter("@id", id));

            if (rows > 0)
                ShowAlert("Payslip rejected.", "warning");
            else
                ShowAlert("Payslip not found.", "warning");
        }
        catch (Exception ex)
        {
            ShowAlert("Error rejecting payslip: " + ex.Message, "danger");
        }
    }

    // =====================================================================
    // SECTION 10: btnBatchExecute_Click
    // =====================================================================

    protected void btnBatchExecute_Click(object sender, EventArgs e)
    {
        string rawIDs = hdnBatchIDs.Value;
        string action = (hdnBatchAction.Value ?? "").ToUpper().Trim();

        if (string.IsNullOrEmpty(rawIDs)) { BindGrid(); LoadStats(); return; }

        string[] parts = rawIDs.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        int updated = 0;
        string currentUser = GetCurrentUser();

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                foreach (string part in parts)
                {
                    int id;
                    if (!int.TryParse(part.Trim(), out id) || id <= 0) continue;

                    if (action == "APPROVE")
                    {
                        int rows = ExecuteNonQueryWithConn(conn,
                            "UPDATE hrm_payslips SET status='APPROVED', approved_by=@user, date_approved=NOW() " +
                            "WHERE ID=@id AND status != 'APPROVED'",
                            new MySqlParameter("@user", currentUser),
                            new MySqlParameter("@id", id));
                        updated += rows;
                    }
                    else if (action == "REJECT")
                    {
                        int rows = ExecuteNonQueryWithConn(conn,
                            "UPDATE hrm_payslips SET status='REJECTED', rejection_reason=@reason, " +
                            "approved_by=NULL, date_approved=NULL WHERE ID=@id",
                            new MySqlParameter("@reason", "Batch rejected by " + currentUser),
                            new MySqlParameter("@id", id));
                        updated += rows;
                    }
                }
            }

            ShowAlert(updated + " payslip(s) updated successfully.", "success");
        }
        catch (Exception ex)
        {
            ShowAlert("Batch operation error: " + ex.Message, "danger");
        }

        hdnBatchIDs.Value = "";
        hdnBatchAction.Value = "";
        BindGrid();
        LoadStats();
    }

    // =====================================================================
    // SECTION 11: btnConfirmBatchReject_Click
    // =====================================================================

    protected void btnConfirmBatchReject_Click(object sender, EventArgs e)
    {
        string rawIDs = hdnBatchIDs.Value;
        string reason = txtBatchRejectReason.Text.Trim();

        if (string.IsNullOrEmpty(rawIDs))
        {
            ShowModalScript("closeBatchRejectModal");
            BindGrid(); LoadStats(); return;
        }

        string[] parts = rawIDs.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        int updated = 0;

        foreach (string part in parts)
        {
            int id;
            if (!int.TryParse(part.Trim(), out id) || id <= 0) continue;
            RejectPayslip(id, reason);
            updated++;
        }

        ShowAlert(updated + " payslip(s) rejected.", "warning");
        ShowModalScript("closeBatchRejectModal");
        txtBatchRejectReason.Text = "";
        hdnBatchIDs.Value = "";
        BindGrid();
        LoadStats();
    }

    // =====================================================================
    // SECTION 12: btnLoadSlipDetail_Click
    // =====================================================================

    protected void btnLoadSlipDetail_Click(object sender, EventArgs e)
    {
        int id = SafeInt(hdnViewSlipID.Value);
        if (id > 0)
        {
            LoadPayslipDetail(id);
            ScriptManager.RegisterStartupScript(this, GetType(), "openSlipModal",
                "document.getElementById('slipDetailModal').style.display='flex';", true);
        }
        else
        {
            ShowAlert("Invalid payslip ID.", "danger");
        }
    }

    // =====================================================================
    // SECTION 13: LoadPayslipDetail
    // =====================================================================

    private void LoadPayslipDetail(int payslipID)
    {
        try
        {
            DataTable dt = ExecuteQuery(
                "SELECT ps.*, e.emp_name, e.EMP_CODE, p.payroll_title " +
                "FROM hrm_payslips ps " +
                "JOIN hrm_employee e ON e.empID = ps.empID " +
                "JOIN hrm_payroll p ON p.ID = ps.payroll_id " +
                "WHERE ps.ID = @id",
                new MySqlParameter("@id", payslipID));

            if (dt == null || dt.Rows.Count == 0)
            {
                litSlipDetailHtml.Text = "<p style='color:#dc3545;font-size:12px;'>Payslip not found.</p>";
                return;
            }

            DataRow r = dt.Rows[0];

            string empName = r["emp_name"].ToString();
            string empCode = r["EMP_CODE"].ToString();
            string payrollTitle = r["payroll_title"].ToString();
            string monthName = r["payroll_month_name"].ToString();
            string year = r["payroll_year"].ToString();
            decimal basicPay = SafeDecimal(r["basic_pay"]);
            decimal grossSalary = SafeDecimal(r["gross_salary"]);
            decimal totalAllowances = SafeDecimal(r["total_allowances"]);
            decimal totalDeductions = SafeDecimal(r["total_deductions"]);
            decimal paye = SafeDecimal(r["paye"]);
            decimal nssf = SafeDecimal(r["nssf"]);
            decimal kabaka = SafeDecimal(r["kabaka_contribution"]);
            decimal localTax = SafeDecimal(r["local_tax"]);
            decimal netSalary = SafeDecimal(r["net_salary"]);
            string status = r["status"].ToString();
            string approvedBy = r["approved_by"] != DBNull.Value ? r["approved_by"].ToString() : "";
            string allowanceDetails = r["allowance_details"] != DBNull.Value ? r["allowance_details"].ToString() : "";
            string deductionDetails = r["deduction_details"] != DBNull.Value ? r["deduction_details"].ToString() : "";

            DateTime dateGenerated = DateTime.MinValue;
            if (r["date_generated"] != DBNull.Value)
                DateTime.TryParse(r["date_generated"].ToString(), out dateGenerated);

            var html = new StringBuilder();
            html.Append("<div class=\"payslip-print\">");

            // Header
            html.Append("<div class=\"payslip-print__header\">");
            html.Append("<h2>Mutesa I Royal University</h2>");
            html.AppendFormat("<h3>PAYSLIP &mdash; {0} {1}</h3>", monthName, year);
            html.Append("<div class=\"payslip-emp-info\">");
            html.AppendFormat("<div><strong>Employee:</strong> {0}</div>", HttpUtility.HtmlEncode(empName));
            html.AppendFormat("<div><strong>Staff #:</strong> {0}</div>", HttpUtility.HtmlEncode(empCode));
            html.AppendFormat("<div><strong>Payroll:</strong> {0}</div>", HttpUtility.HtmlEncode(payrollTitle));
            html.AppendFormat("<div><strong>Generated:</strong> {0}</div>",
                dateGenerated != DateTime.MinValue ? dateGenerated.ToString("dd MMM yyyy") : "-");
            html.Append("</div>");
            html.Append("</div>"); // end payslip-print__header

            // Earnings table
            html.Append("<table class=\"payslip-print__table\">");
            html.Append("<thead><tr><th>EARNINGS</th><th class=\"right\">AMOUNT (UGX)</th></tr></thead>");
            html.Append("<tbody>");
            html.AppendFormat("<tr><td>Basic Pay</td><td class=\"right\">{0}</td></tr>", basicPay.ToString("N0"));

            // Parse allowance_details: "TypeName:Amount|TypeName:Amount|..."
            if (!string.IsNullOrWhiteSpace(allowanceDetails))
            {
                string[] allowItems = allowanceDetails.Split(new char[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string item in allowItems)
                {
                    string[] parts = item.Split(new char[] { ':' }, 2);
                    if (parts.Length == 2)
                    {
                        string aName = parts[0].Trim();
                        decimal aAmt;
                        decimal.TryParse(parts[1].Trim(), out aAmt);
                        html.AppendFormat("<tr><td>{0}</td><td class=\"right\">{1}</td></tr>",
                            HttpUtility.HtmlEncode(aName), aAmt.ToString("N0"));
                    }
                }
            }

            html.AppendFormat(
                "<tr class=\"subtotal\"><td><strong>GROSS SALARY</strong></td><td class=\"right\"><strong>{0}</strong></td></tr>",
                grossSalary.ToString("N0"));
            html.Append("</tbody></table>");

            // Deductions table
            html.Append("<table class=\"payslip-print__table\" style=\"margin-top:12px\">");
            html.Append("<thead><tr><th>DEDUCTIONS</th><th class=\"right\">AMOUNT (UGX)</th></tr></thead>");
            html.Append("<tbody>");
            html.AppendFormat("<tr><td>PAYE</td><td class=\"right\">{0}</td></tr>", paye.ToString("N0"));
            html.AppendFormat("<tr><td>NSSF (Employee)</td><td class=\"right\">{0}</td></tr>", nssf.ToString("N0"));

            if (kabaka > 0)
                html.AppendFormat("<tr><td>Kabaka / Kingdom Contribution</td><td class=\"right\">{0}</td></tr>", kabaka.ToString("N0"));

            if (localTax > 0)
                html.AppendFormat("<tr><td>Local Service Tax</td><td class=\"right\">{0}</td></tr>", localTax.ToString("N0"));

            // Parse deduction_details
            if (!string.IsNullOrWhiteSpace(deductionDetails))
            {
                string[] dedItems = deductionDetails.Split(new char[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string item in dedItems)
                {
                    string[] parts = item.Split(new char[] { ':' }, 2);
                    if (parts.Length == 2)
                    {
                        string dName = parts[0].Trim();
                        decimal dAmt;
                        decimal.TryParse(parts[1].Trim(), out dAmt);
                        html.AppendFormat("<tr><td>{0}</td><td class=\"right\">{1}</td></tr>",
                            HttpUtility.HtmlEncode(dName), dAmt.ToString("N0"));
                    }
                }
            }

            html.AppendFormat(
                "<tr class=\"subtotal\"><td><strong>TOTAL DEDUCTIONS</strong></td><td class=\"right\"><strong>{0}</strong></td></tr>",
                totalDeductions.ToString("N0"));
            html.Append("</tbody></table>");

            // Net salary
            html.Append("<div class=\"payslip-print__net\">");
            html.Append("<span>NET SALARY</span>");
            html.AppendFormat("<strong>UGX {0}</strong>", netSalary.ToString("N0"));
            html.Append("</div>");

            // Footer
            html.Append("<div class=\"payslip-print__footer\">");
            html.AppendFormat("Status: {0}", GetPayslipStatusBadge(status));
            if (!string.IsNullOrEmpty(approvedBy))
                html.AppendFormat(" &nbsp;|&nbsp; Approved by: <strong>{0}</strong>", HttpUtility.HtmlEncode(approvedBy));
            html.Append("</div>");

            html.Append("</div>"); // end payslip-print

            litSlipDetailHtml.Text = html.ToString();
        }
        catch (Exception ex)
        {
            litSlipDetailHtml.Text = "<p style='color:#dc3545;font-size:12px;'>Error loading payslip: " +
                HttpUtility.HtmlEncode(ex.Message) + "</p>";
        }
    }

    // =====================================================================
    // SECTION 14: gvPayslips_HtmlRowCreated
    // =====================================================================

    protected void gvPayslips_HtmlRowCreated(object sender, ASPxGridViewTableRowEventArgs e)
    {
        if (e.RowType != GridViewRowType.Data) return;
        string status = (gvPayslips.GetRowValues(e.VisibleIndex, "status") ?? "").ToString().ToUpper();
        if (status == "APPROVED") e.Row.CssClass = "pr-row-settled";
        else if (status == "REJECTED") e.Row.CssClass = "pr-row-cancelled";
        else e.Row.CssClass = "pr-row-pending";
    }

    // =====================================================================
    // SECTION 15: Filter / Search events
    // =====================================================================

    protected void ddlFilter_Changed(object sender, EventArgs e)
    {
        BindGrid();
        LoadStats();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid();
        LoadStats();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlFilterPayroll.SelectedIndex = 0;
        ddlFilterEmployee.SelectedIndex = 0;
        ddlFilterMonth.SelectedIndex = 0;
        txtFilterYear.Text = "";
        ddlFilterStatus.SelectedIndex = 0;
        ddlPageSize.SelectedIndex = 0;
        BindGrid();
        LoadStats();
    }

    protected void ddlPageSize_Changed(object sender, EventArgs e)
    {
        int pageSize = 25;
        int.TryParse(ddlPageSize.SelectedValue, out pageSize);
        gvPayslips.SettingsPager.PageSize = pageSize;
        BindGrid();
        LoadStats();
    }

    // =====================================================================
    // SECTION 16: Template Helpers (called from ASPX DataItemTemplates)
    // =====================================================================

    protected string GetPayslipStatusBadge(object statusObj)
    {
        string status = (statusObj ?? "").ToString().ToUpper().Trim();
        string cssClass, label;
        switch (status)
        {
            case "APPROVED":
                cssClass = "slip-badge--approved";
                label = "Approved";
                break;
            case "REJECTED":
                cssClass = "slip-badge--rejected";
                label = "Rejected";
                break;
            default:
                cssClass = "slip-badge--pending";
                label = "Pending";
                break;
        }
        return string.Format("<span class=\"slip-badge {0}\">{1}</span>", cssClass, label);
    }

    protected string GetPayslipActionHtml(object idObj, object statusObj)
    {
        int id = SafeInt(idObj);
        string status = (statusObj ?? "").ToString().ToUpper().Trim();

        var sb = new StringBuilder();
        sb.Append("<div class=\"cd-action-wrapper\">");
        sb.Append("<button type=\"button\" class=\"cd-action-btn\" onclick=\"toggleActionPopover(this,event)\" title=\"Actions\">&#8942;</button>");
        sb.Append("<div class=\"cd-action-popover\">");

        // View
        sb.AppendFormat(
            "<button type=\"button\" class=\"cd-action-popover__item\" onclick=\"viewSlip({0})\">" +
            "<svg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor' stroke-width='2'>" +
            "<path stroke-linecap='round' stroke-linejoin='round' d='M15 12a3 3 0 11-6 0 3 3 0 016 0z'/>" +
            "<path stroke-linecap='round' stroke-linejoin='round' d='M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z'/>" +
            "</svg>View Payslip</button>", id);

        sb.Append("<div class=\"cd-action-popover__divider\"></div>");

        // Approve (if not already approved)
        if (status != "APPROVED")
        {
            sb.AppendFormat(
                "<button type=\"button\" class=\"cd-action-popover__item cd-action-popover__item--success\" onclick=\"approveSlip({0})\">" +
                "<svg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor' stroke-width='2'>" +
                "<path stroke-linecap='round' stroke-linejoin='round' d='M5 13l4 4L19 7'/>" +
                "</svg>Approve</button>", id);
        }

        // Reject (if not already rejected)
        if (status != "REJECTED")
        {
            sb.AppendFormat(
                "<button type=\"button\" class=\"cd-action-popover__item cd-action-popover__item--danger\" onclick=\"openRejectModal({0})\">" +
                "<svg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor' stroke-width='2'>" +
                "<path stroke-linecap='round' stroke-linejoin='round' d='M6 18L18 6M6 6l12 12'/>" +
                "</svg>Reject</button>", id);
        }

        sb.Append("</div>"); // end cd-action-popover
        sb.Append("</div>"); // end cd-action-wrapper
        return sb.ToString();
    }

    protected string FormatCurrency(object val)
    {
        decimal d = SafeDecimal(val);
        return d.ToString("N0");
    }

    protected string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "-";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy");
        return "-";
    }

    protected string TruncStr(object val, int maxLen)
    {
        if (val == null || val == DBNull.Value) return "";
        string s = val.ToString();
        if (s.Length <= maxLen) return s;
        return s.Substring(0, maxLen - 1) + "…";
    }

    private void ShowModalScript(string jsFunction)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "modalScript_" + jsFunction,
            jsFunction + "();", true);
    }
}
