using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Payment Vouchers — creation, viewing, and approval.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ double for money → decimal via MoneyHelper
///  ✓ Duplicated GetAccountType → AccountCache.GetAccountType
///  ✓ LoadAccountsCombos → AccountCache.BindAccountDropDownWithSelect
///  ✓ No financial period check → FinancePeriod added to create + approve
///  ✓ In-memory stats loop → SQL GROUP BY
///  ✓ No logging → FinanceLogger for create/approve/errors
///  ✓ No pagination → LIMIT 500 on voucher list
///  ✓ Date defaults → FinancePeriod.GetDefaultDateRange
/// </summary>
public partial class COOPERP_NewScreens_PaymentVouchers : System.Web.UI.Page
{
    private const string PAGE_NAME = "PaymentVouchers";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var range = FinancePeriod.GetDefaultDateRange();
            txtStartDate.Text = range.Item1.ToString("yyyy-MM-dd");
            txtEndDate.Text   = range.Item2.ToString("yyyy-MM-dd");
            txtVoucherDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

            // Cached account dropdowns — single DB hit
            AccountCache.BindAccountDropDownWithSelect(ddlDRAccount);
            AccountCache.BindAccountDropDownWithSelect(ddlCRAccount);

            LoadVouchers();
        }
    }

    // ───────────────────────── Voucher List ───────────────────────────────

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadVouchers();
    }

    private void LoadVouchers()
    {
        try
        {
            DateTime startDate, endDate;
            DateTime.TryParse(txtStartDate.Text, out startDate);
            DateTime.TryParse(txtEndDate.Text, out endDate);
            if (startDate == DateTime.MinValue) startDate = DateTime.Today.AddMonths(-1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Today;

            string vType = ddlVoucherType.SelectedValue;

            // Build query with optional type filter + bounded result
            string sql = @"SELECT VoucherNo, Vouchertype, voucherDate, Teller, PostStatus 
                           FROM fin_vouchernumbers 
                           WHERE voucherDate BETWEEN @sDate AND @eDate";

            var parms = new System.Collections.Generic.List<MySqlParameter>
            {
                FinanceDB.P("@sDate", startDate),
                FinanceDB.P("@eDate", endDate)
            };

            if (!string.IsNullOrEmpty(vType))
            {
                sql += " AND Vouchertype = @typ";
                parms.Add(FinanceDB.P("@typ", vType));
            }
            sql += " ORDER BY VoucherNo DESC LIMIT 500";

            DataTable dt = FinanceDB.ExecuteDataTable(sql, parms.ToArray());
            rptVouchers.DataSource = dt;
            rptVouchers.DataBind();
            phNoVouchers.Visible = dt.Rows.Count == 0;

            // FIX: SQL-based stats instead of in-memory loop
            LoadVoucherStats(startDate, endDate, vType, dt.Rows.Count);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadVouchers", ex);
        }
    }

    /// <summary>
    /// Computes voucher stats using SQL GROUP BY instead of iterating DataTable in memory.
    /// </summary>
    private void LoadVoucherStats(DateTime startDate, DateTime endDate, string vType, int totalCount)
    {
        string statsSql = @"SELECT PostStatus, COUNT(*) AS cnt 
                            FROM fin_vouchernumbers 
                            WHERE voucherDate BETWEEN @sDate AND @eDate";

        var parms = new System.Collections.Generic.List<MySqlParameter>
        {
            FinanceDB.P("@sDate", startDate),
            FinanceDB.P("@eDate", endDate)
        };

        if (!string.IsNullOrEmpty(vType))
        {
            statsSql += " AND Vouchertype = @typ";
            parms.Add(FinanceDB.P("@typ", vType));
        }
        statsSql += " GROUP BY PostStatus";

        DataTable stats = FinanceDB.ExecuteDataTable(statsSql, parms.ToArray());

        int newCount = 0, approvedCount = 0;
        foreach (DataRow row in stats.Rows)
        {
            string status = row["PostStatus"].ToString();
            int cnt = Convert.ToInt32(row["cnt"]);
            if (status == "New") newCount = cnt;
            else if (status == "Approved") approvedCount = cnt;
        }

        litStatTotal.Text = totalCount.ToString("N0");
        litStatNew.Text = newCount.ToString("N0");
        litStatApproved.Text = approvedCount.ToString("N0");
        litVoucherCount.Text = string.Format("Showing <strong>{0}</strong> voucher(s)", totalCount);
    }

    // ───────────────────────── Create Voucher ─────────────────────────────

    protected void btnNewVoucher_Click(object sender, EventArgs e)
    {
        pnlCreate.Visible = true;
    }

    protected void btnCancelCreate_Click(object sender, EventArgs e)
    {
        pnlCreate.Visible = false;
    }

    protected void btnConfirmCreate_Click(object sender, EventArgs e)
    {
        string drAcc = ddlDRAccount.SelectedValue;
        string crAcc = ddlCRAccount.SelectedValue;
        decimal amount = MoneyHelper.ParseMoney(txtAmount.Text);
        string drPart = txtDRParticulars.Text.Trim();
        string crPart = txtCRParticulars.Text.Trim();
        DateTime vDate;
        DateTime.TryParse(txtVoucherDate.Text, out vDate);
        if (vDate == DateTime.MinValue) vDate = DateTime.Today;

        if (string.IsNullOrEmpty(drAcc) || string.IsNullOrEmpty(crAcc) || amount <= 0)
        {
            ShowMessage("Please select both accounts and enter a valid amount.", false);
            return;
        }

        // FIX: Financial period check (was completely missing)
        if (!FinancePeriod.IsDateInOpenPeriod(vDate))
        {
            ShowMessage("Cannot create voucher: the voucher date is not in an open financial period.", false);
            return;
        }

        try
        {
            // Get account types from cache (no DB round-trip)
            string drType = AccountCache.GetAccountType(drAcc);
            string crType = AccountCache.GetAccountType(crAcc);
            string user = HttpContext.Current.User.Identity.Name;

            // Get next voucher number via SP
            int voucherNo = 0;
            FinanceDB.ExecuteReader(
                "CALL fin_GetLatestVoucherNo(@usr, @typ, @cat)",
                reader => { if (reader.Read()) voucherNo = reader.GetInt32(0); },
                FinanceDB.P("@usr", user),
                FinanceDB.P("@typ", "Payment"),
                FinanceDB.P("@cat", "Payment"));

            // Create voucher via SP
            FinanceDB.ExecuteNonQuerySP("fin_VoucherCreator",
                FinanceDB.P("@vNo", voucherNo),
                FinanceDB.P("@CRaccountcode", crAcc),
                FinanceDB.P("@CRaccountType", crType),
                FinanceDB.P("@CRParticulars", string.IsNullOrEmpty(crPart) ? "Payment - " + crAcc : crPart),
                FinanceDB.P("@DRaccountcode", drAcc),
                FinanceDB.P("@DRaccounttype", drType),
                FinanceDB.P("@DRParticulars", string.IsNullOrEmpty(drPart) ? "Payment - " + drAcc : drPart),
                FinanceDB.P("@transaction_amount", amount),
                FinanceDB.P("@voucherNo", voucherNo),
                FinanceDB.P("@transactionDate", vDate),
                FinanceDB.P("@teller", user));

            FinanceLogger.LogVoucherCreated(voucherNo, "Payment", amount, user);
            ShowMessage("Payment Voucher #" + voucherNo + " created successfully.", true);
            pnlCreate.Visible = false;
            txtAmount.Text = "";
            txtDRParticulars.Text = "";
            txtCRParticulars.Text = "";
            LoadVouchers();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "CreateVoucher", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    // ───────────────────────── Voucher Detail ─────────────────────────────

    protected void rptVouchers_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "ViewVoucher")
        {
            int vno = Convert.ToInt32(e.CommandArgument);
            LoadVoucherDetail(vno);
        }
    }

    private void LoadVoucherDetail(int voucherNo)
    {
        pnlDetail.Visible = true;
        lblVoucherNo.Text = voucherNo.ToString();

        try
        {
            // Get status
            string status = FinanceDB.ExecuteScalar<string>(
                "SELECT PostStatus FROM fin_vouchernumbers WHERE VoucherNo = @vno",
                FinanceDB.P("@vno", voucherNo)) ?? "";
            lblVoucherStatus.Text = status;
            btnApproveVoucher.Visible = (status == "New");

            // Get transactions
            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT TID, accountcode, account_type, transactionType, transaction_amount, particulars, transactionDate 
                  FROM fin_voucher WHERE voucherNo = @vno ORDER BY TID",
                FinanceDB.P("@vno", voucherNo));
            rptVoucherTrans.DataSource = dt;
            rptVoucherTrans.DataBind();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadVoucherDetail", ex);
        }
    }

    // ───────────────────────── Approve Voucher ────────────────────────────

    protected void btnApproveVoucher_Click(object sender, EventArgs e)
    {
        int vno = 0;
        int.TryParse(lblVoucherNo.Text, out vno);
        if (vno == 0) return;

        // FIX: Financial period check on approval (was missing)
        if (!FinancePeriod.IsInOpenFinancialPeriod())
        {
            ShowMessage("Cannot approve voucher: No open financial period.", false);
            return;
        }

        try
        {
            FinanceDB.ExecuteNonQuerySP("fin_ApproveVoucher",
                FinanceDB.P("@VNo", vno));

            FinanceLogger.LogVoucherApproved(vno, HttpContext.Current.User.Identity.Name);
            ShowMessage("Voucher #" + vno + " approved.", true);
            LoadVoucherDetail(vno);
            LoadVouchers();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "ApproveVoucher", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnCloseDetail_Click(object sender, EventArgs e)
    {
        pnlDetail.Visible = false;
    }

    // ───────────────────────── UI Helpers ──────────────────────────────────

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = "<div class='ft-alert " + (success ? "ft-alert--success" : "ft-alert--error") + "'>" +
            System.Web.HttpUtility.HtmlEncode(msg) + "</div>";
    }
}
