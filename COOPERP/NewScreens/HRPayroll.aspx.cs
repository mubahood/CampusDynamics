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

public partial class COOPERP_NewScreens_HRPayroll : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadYearDropdown();
            txtPayrollYear.Text = DateTime.Now.Year.ToString();
            ddlPayrollMonth.SelectedValue = DateTime.Now.Month.ToString();
        }
        BindPayrollGrid();
        LoadStats();
    }

    #region Data Loading

    private void LoadYearDropdown()
    {
        ddlPayrollYear.Items.Clear();
        int year = DateTime.Now.Year;
        for (int y = year + 1; y >= year - 5; y--)
        {
            ddlPayrollYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        }
        ddlPayrollYear.SelectedValue = year.ToString();
    }

    private void LoadStats()
    {
        string year = ddlPayrollYear.SelectedValue;
        DataTable dt = ExecuteQuery(@"
            SELECT COUNT(DISTINCT p.ID) AS total_payrolls,
                COALESCE(SUM(pd.gross_pay),0) AS total_gross,
                COALESCE(SUM(pd.total_deductions),0) AS total_deductions,
                COALESCE(SUM(pd.net_pay),0) AS total_net
            FROM hrm_payroll p
            LEFT JOIN hrm_payroll_details pd ON pd.payrollID = p.ID
            WHERE p.payroll_year = @yr",
            new MySqlParameter("@yr", year));

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litTotalPayrolls.Text = r["total_payrolls"].ToString();
            litTotalGross.Text = FormatCurrency(r["total_gross"]);
            litTotalDeductions.Text = FormatCurrency(r["total_deductions"]);
            litTotalNet.Text = FormatCurrency(r["total_net"]);
        }
    }

    #endregion

    #region Payroll Periods Grid

    private void BindPayrollGrid()
    {
        string year = ddlPayrollYear.SelectedValue;
        DataTable dt = ExecuteQuery(@"
            SELECT p.ID, p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                p.payroll_comments, p.prepared_by, p.checked_by, p.approved_by,
                p.total_amount, p.lockStatus,
                COUNT(pd.ID) AS staff_count
            FROM hrm_payroll p
            LEFT JOIN hrm_payroll_details pd ON pd.payrollID = p.ID
            WHERE p.payroll_year = @yr
            GROUP BY p.ID, p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                p.payroll_comments, p.prepared_by, p.checked_by, p.approved_by,
                p.total_amount, p.lockStatus
            ORDER BY p.payroll_month DESC",
            new MySqlParameter("@yr", year));

        gvPayrolls.DataSource = dt;
        gvPayrolls.DataBind();
    }

    #endregion

    #region Create Payroll

    protected void btnCreatePayroll_Click(object sender, EventArgs e)
    {
        string title = txtPayrollTitle.Text.Trim();
        if (string.IsNullOrEmpty(title))
        {
            ShowModalError("createPayrollModal", "createResult", "Payroll title is required.");
            return;
        }

        int month = Convert.ToInt32(ddlPayrollMonth.SelectedValue);
        int year;
        if (!int.TryParse(txtPayrollYear.Text, out year))
        {
            ShowModalError("createPayrollModal", "createResult", "Invalid year.");
            return;
        }

        string user = "";
        if (HttpContext.Current.User != null && HttpContext.Current.User.Identity != null)
        {
            user = HttpContext.Current.User.Identity.Name;
        }

        ExecuteNonQuery(@"INSERT INTO hrm_payroll 
            (payroll_title, payroll_month, payroll_year, payroll_comments, prepared_by, payroll_date, lockStatus)
            VALUES (@title, @month, @year, @comments, @user, @dt, 'OPEN')",
            new MySqlParameter("@title", title),
            new MySqlParameter("@month", month),
            new MySqlParameter("@year", year),
            new MySqlParameter("@comments", txtPayrollComments.Text.Trim()),
            new MySqlParameter("@user", user),
            new MySqlParameter("@dt", DateTime.Now));

        txtPayrollTitle.Text = "";
        txtPayrollComments.Text = "";
        BindPayrollGrid();
        LoadStats();
    }

    #endregion

    #region Generate Payroll

    protected void btnGenPayroll_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnGeneratePayrollID.Value, out payrollID)) return;

        // Get all staff with active contracts
        DataTable dtStaff = ExecuteQuery(@"
            SELECT e.empID, IFNULL(ps.basicpay, c.fixedamount) AS basic_pay
            FROM hrm_employee e
            JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
            )
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            WHERE c.contractStatus = 'VALID'");

        if (dtStaff.Rows.Count == 0) return;

        decimal totalAmount = 0;

        foreach (DataRow staff in dtStaff.Rows)
        {
            int empID = Convert.ToInt32(staff["empID"]);
            decimal basicPay = staff["basic_pay"] != DBNull.Value ? Convert.ToDecimal(staff["basic_pay"]) : 0;

            // Check if already exists
            DataTable dtExist = ExecuteQuery(
                "SELECT ID FROM hrm_payroll_details WHERE payrollID = @pid AND empID = @eid",
                new MySqlParameter("@pid", payrollID),
                new MySqlParameter("@eid", empID));

            if (dtExist.Rows.Count > 0) continue;

            // Calculate allowances
            decimal totalAllowances = 0;
            DataTable dtAllow = ExecuteQuery(@"
                SELECT ad.dedall_amount, IFNULL(das.custom_amount, ad.dedall_amount) AS amount, ad.computation_by
                FROM hrm_allowance_deductions ad
                JOIN hrm_ded_allowance_stafflist das ON das.ded_allID = ad.ID
                LEFT JOIN hrm_exemptions ex ON ex.empID = @eid AND ex.ded_allID = ad.ID
                WHERE das.empID = @eid AND ad.ded_allowance = 'ALLOWANCE' AND ex.ID IS NULL",
                new MySqlParameter("@eid", empID));

            foreach (DataRow a in dtAllow.Rows)
            {
                decimal amt = a["amount"] != DBNull.Value ? Convert.ToDecimal(a["amount"]) : 0;
                string compBy = a["computation_by"] != null ? a["computation_by"].ToString() : "";
                if (compBy.ToUpper() == "PERCENTAGE")
                    totalAllowances += basicPay * amt / 100;
                else
                    totalAllowances += amt;
            }

            // Calculate deductions
            decimal totalDeductions = 0;
            DataTable dtDed = ExecuteQuery(@"
                SELECT ad.dedall_amount, IFNULL(das.custom_amount, ad.dedall_amount) AS amount, ad.computation_by
                FROM hrm_allowance_deductions ad
                JOIN hrm_ded_allowance_stafflist das ON das.ded_allID = ad.ID
                LEFT JOIN hrm_exemptions ex ON ex.empID = @eid AND ex.ded_allID = ad.ID
                WHERE das.empID = @eid AND ad.ded_allowance = 'DEDUCTION' AND ex.ID IS NULL",
                new MySqlParameter("@eid", empID));

            foreach (DataRow d in dtDed.Rows)
            {
                decimal amt = d["amount"] != DBNull.Value ? Convert.ToDecimal(d["amount"]) : 0;
                string compBy = d["computation_by"] != null ? d["computation_by"].ToString() : "";
                if (compBy.ToUpper() == "PERCENTAGE")
                    totalDeductions += basicPay * amt / 100;
                else
                    totalDeductions += amt;
            }

            decimal grossPay = basicPay + totalAllowances;

            // Standard NSSF: 5% employee contribution
            decimal nssf = basicPay * 0.05M;

            // PAYE calculation (URA Uganda brackets simplified)
            decimal taxableIncome = grossPay - nssf;
            decimal paye = CalculatePAYE(taxableIncome);

            totalDeductions += paye + nssf;
            decimal netPay = grossPay - totalDeductions;
            if (netPay < 0) netPay = 0;

            totalAmount += netPay;

            ExecuteNonQuery(@"INSERT INTO hrm_payroll_details 
                (payrollID, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay)
                VALUES (@pid, @eid, @basic, @paye, @nssf, @allow, @ded, @gross, @net)",
                new MySqlParameter("@pid", payrollID),
                new MySqlParameter("@eid", empID),
                new MySqlParameter("@basic", basicPay),
                new MySqlParameter("@paye", paye),
                new MySqlParameter("@nssf", nssf),
                new MySqlParameter("@allow", totalAllowances),
                new MySqlParameter("@ded", totalDeductions),
                new MySqlParameter("@gross", grossPay),
                new MySqlParameter("@net", netPay));

            // Store monthly allowances/deductions breakdown
            foreach (DataRow a in dtAllow.Rows)
            {
                decimal amt = a["amount"] != DBNull.Value ? Convert.ToDecimal(a["amount"]) : 0;
                string compBy = a["computation_by"] != null ? a["computation_by"].ToString() : "";
                decimal finalAmt = compBy.ToUpper() == "PERCENTAGE" ? basicPay * amt / 100 : amt;
                // We'd store to hrm_monthly_ded_allowance if needed
            }
        }

        // Update total
        ExecuteNonQuery("UPDATE hrm_payroll SET total_amount = @total WHERE ID = @pid",
            new MySqlParameter("@total", totalAmount),
            new MySqlParameter("@pid", payrollID));

        BindPayrollGrid();
        LoadStats();

        // Auto-open details
        hdnSelectedPayrollID.Value = payrollID.ToString();
        ShowPayrollDetails(payrollID);
    }

    private decimal CalculatePAYE(decimal taxableMonthly)
    {
        // Uganda PAYE brackets (monthly)
        // 0 - 235,000: 0%
        // 235,001 - 335,000: 10%
        // 335,001 - 410,000: 20%
        // Above 410,000: 30%
        // Plus 10% surcharge above 10,000,000
        decimal paye = 0;

        if (taxableMonthly <= 235000) return 0;

        if (taxableMonthly <= 335000)
        {
            paye = (taxableMonthly - 235000) * 0.10M;
        }
        else if (taxableMonthly <= 410000)
        {
            paye = (335000 - 235000) * 0.10M + (taxableMonthly - 335000) * 0.20M;
        }
        else
        {
            paye = (335000 - 235000) * 0.10M + (410000 - 335000) * 0.20M + (taxableMonthly - 410000) * 0.30M;
        }

        // 10% surcharge above 10M
        if (taxableMonthly > 10000000)
        {
            paye += (taxableMonthly - 10000000) * 0.10M;
        }

        return Math.Round(paye, 0);
    }

    #endregion

    #region View Payroll Details

    protected void btnViewPayroll_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnSelectedPayrollID.Value, out payrollID)) return;
        ShowPayrollDetails(payrollID);
    }

    private void ShowPayrollDetails(int payrollID)
    {
        // Header
        DataTable dtHeader = ExecuteQuery("SELECT payroll_title FROM hrm_payroll WHERE ID = @id", new MySqlParameter("@id", payrollID));
        if (dtHeader.Rows.Count > 0)
            litPayrollTitle.Text = HttpUtility.HtmlEncode(dtHeader.Rows[0]["payroll_title"].ToString());

        // Details
        DataTable dt = ExecuteQuery(@"
            SELECT pd.ID, pd.empID, pd.basic_pay, pd.paye, pd.nssf, pd.total_allowances,
                pd.total_deductions, pd.gross_pay, pd.net_pay,
                e.EMP_CODE, e.emp_name
            FROM hrm_payroll_details pd
            JOIN hrm_employee e ON e.empID = pd.empID
            WHERE pd.payrollID = @pid
            ORDER BY e.emp_name",
            new MySqlParameter("@pid", payrollID));

        gvPayrollDetails.DataSource = dt;
        gvPayrollDetails.DataBind();

        // Summary
        decimal totalBasic = 0, totalAllow = 0, totalGross = 0, totalPAYE = 0, totalNSSF = 0, totalDed = 0, totalNet = 0;
        foreach (DataRow r in dt.Rows)
        {
            totalBasic += r["basic_pay"] != DBNull.Value ? Convert.ToDecimal(r["basic_pay"]) : 0;
            totalAllow += r["total_allowances"] != DBNull.Value ? Convert.ToDecimal(r["total_allowances"]) : 0;
            totalGross += r["gross_pay"] != DBNull.Value ? Convert.ToDecimal(r["gross_pay"]) : 0;
            totalPAYE += r["paye"] != DBNull.Value ? Convert.ToDecimal(r["paye"]) : 0;
            totalNSSF += r["nssf"] != DBNull.Value ? Convert.ToDecimal(r["nssf"]) : 0;
            totalDed += r["total_deductions"] != DBNull.Value ? Convert.ToDecimal(r["total_deductions"]) : 0;
            totalNet += r["net_pay"] != DBNull.Value ? Convert.ToDecimal(r["net_pay"]) : 0;
        }

        litDetStaff.Text = dt.Rows.Count.ToString();
        litDetBasic.Text = totalBasic.ToString("N0");
        litDetAllow.Text = totalAllow.ToString("N0");
        litDetGross.Text = totalGross.ToString("N0");
        litDetPAYE.Text = totalPAYE.ToString("N0");
        litDetNSSF.Text = totalNSSF.ToString("N0");
        litDetOther.Text = (totalDed - totalPAYE - totalNSSF).ToString("N0");
        litDetNet.Text = totalNet.ToString("N0");

        pnlPayrollDetails.Visible = true;
    }

    protected void btnCloseDetails_Click(object sender, EventArgs e)
    {
        pnlPayrollDetails.Visible = false;
    }

    protected void gvPayrollDetails_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int detailID = Convert.ToInt32(e.Keys["ID"]);

        decimal basicPay = Convert.ToDecimal(e.NewValues["basic_pay"]);
        decimal allowances = Convert.ToDecimal(e.NewValues["total_allowances"]);
        decimal grossPay = Convert.ToDecimal(e.NewValues["gross_pay"]);
        decimal paye = Convert.ToDecimal(e.NewValues["paye"]);
        decimal nssf = Convert.ToDecimal(e.NewValues["nssf"]);
        decimal deductions = Convert.ToDecimal(e.NewValues["total_deductions"]);
        decimal netPay = Convert.ToDecimal(e.NewValues["net_pay"]);

        ExecuteNonQuery(@"UPDATE hrm_payroll_details SET 
            basic_pay=@basic, total_allowances=@allow, gross_pay=@gross, paye=@paye, nssf=@nssf, 
            total_deductions=@ded, net_pay=@net WHERE ID=@id",
            new MySqlParameter("@basic", basicPay),
            new MySqlParameter("@allow", allowances),
            new MySqlParameter("@gross", grossPay),
            new MySqlParameter("@paye", paye),
            new MySqlParameter("@nssf", nssf),
            new MySqlParameter("@ded", deductions),
            new MySqlParameter("@net", netPay),
            new MySqlParameter("@id", detailID));

        e.Cancel = true;
        gvPayrollDetails.CancelEdit();

        int payrollID;
        if (int.TryParse(hdnSelectedPayrollID.Value, out payrollID))
            ShowPayrollDetails(payrollID);
    }

    #endregion

    #region Grid Events

    protected void gvPayrolls_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int payrollID = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("DELETE FROM hrm_monthly_ded_allowance WHERE payrollID = @id", new MySqlParameter("@id", payrollID));
        ExecuteNonQuery("DELETE FROM hrm_payroll_details WHERE payrollID = @id", new MySqlParameter("@id", payrollID));
        ExecuteNonQuery("DELETE FROM hrm_payroll WHERE ID = @id", new MySqlParameter("@id", payrollID));

        e.Cancel = true;
        gvPayrolls.CancelEdit();
        BindPayrollGrid();
        LoadStats();
    }

    protected void gvPayrolls_CustomButton(object sender, ASPxGridViewCustomButtonCallbackEventArgs e)
    {
        // placeholder for custom buttons
    }

    protected void ddlPayrollYear_Changed(object sender, EventArgs e)
    {
        BindPayrollGrid();
        LoadStats();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        BindPayrollGrid();
        LoadStats();
    }

    #endregion

    #region Helpers

    protected string FormatCurrency(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d))
            return d.ToString("N0");
        return val.ToString();
    }

    protected string GetViewDetailsScript(object id)
    {
        return "viewPayrollDetails(" + id + ")";
    }

    protected string GetGenerateScript(object id)
    {
        return "generatePayroll(" + id + ")";
    }

    protected string GetPayrollActionHtml(object id)
    {
        string pid = id.ToString();
        return "<a href='javascript:void(0)' onclick='viewPayrollDetails(" + pid + ")' style='font-size:10px;color:#174DA4;text-decoration:none;font-weight:600;margin-right:8px;'>View Details</a>" +
            "<a href='javascript:void(0)' onclick='generatePayroll(" + pid + ")' style='font-size:10px;color:#28a745;text-decoration:none;font-weight:600;'>Generate</a>";
    }

    protected string GetLockBadge(object val)
    {
        string s = (val != null && val != DBNull.Value) ? val.ToString().ToUpper() : "OPEN";
        if (s == "LOCKED" || s == "1")
            return "<span class='hr-badge hr-badge--locked'>LOCKED</span>";
        return "<span class='hr-badge hr-badge--open'>OPEN</span>";
    }

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
