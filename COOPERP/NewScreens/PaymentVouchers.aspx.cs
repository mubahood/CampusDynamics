using System;
using System.Data;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_PaymentVouchers : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtVoucherDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            LoadAccountsCombos();
            LoadVouchers();
        }
    }

    private void LoadAccountsCombos()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT AccountCode, AccountName FROM fin_subaccounts ORDER BY AccountCode", conn))
            {
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        cboDRAccount.DataSource = dt;
        cboDRAccount.DataBind();
        cboCRAccount.DataSource = dt;
        cboCRAccount.DataBind();
    }

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadVouchers();
    }

    private void LoadVouchers()
    {
        DateTime startDate, endDate;
        DateTime.TryParse(txtStartDate.Text, out startDate);
        DateTime.TryParse(txtEndDate.Text, out endDate);
        if (startDate == DateTime.MinValue) startDate = DateTime.Today.AddMonths(-1);
        if (endDate == DateTime.MinValue) endDate = DateTime.Today;

        string vType = ddlVoucherType.SelectedValue;

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT VoucherNo, Vouchertype, voucherDate, Teller, PostStatus 
                           FROM fin_vouchernumbers 
                           WHERE voucherDate BETWEEN @sDate AND @eDate";
            if (!string.IsNullOrEmpty(vType))
                sql += " AND Vouchertype = @typ";
            sql += " ORDER BY VoucherNo DESC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sDate", startDate);
                cmd.Parameters.AddWithValue("@eDate", endDate);
                if (!string.IsNullOrEmpty(vType))
                    cmd.Parameters.AddWithValue("@typ", vType);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        gvVouchers.DataSource = dt;
        gvVouchers.DataBind();
    }

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
        string drAcc = cboDRAccount.Value != null ? cboDRAccount.Value.ToString() : "";
        string crAcc = cboCRAccount.Value != null ? cboCRAccount.Value.ToString() : "";
        double amount = 0;
        double.TryParse(txtAmount.Text, out amount);
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

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Get account types
                string drType = GetAccountType(conn, drAcc);
                string crType = GetAccountType(conn, crAcc);
                string user = HttpContext.Current.User.Identity.Name;

                // Get next voucher number
                int voucherNo = 0;
                using (MySqlCommand cmd = new MySqlCommand("fin_GetLatestVoucherNo", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usr", user);
                    cmd.Parameters.AddWithValue("@typ", "Payment");
                    cmd.Parameters.AddWithValue("@cat", "Payment");
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                            voucherNo = reader.GetInt32(0);
                    }
                }

                // Create voucher
                using (MySqlCommand cmd = new MySqlCommand("fin_VoucherCreator", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@vNo", voucherNo);
                    cmd.Parameters.AddWithValue("@CRaccountcode", crAcc);
                    cmd.Parameters.AddWithValue("@CRaccountType", crType);
                    cmd.Parameters.AddWithValue("@CRParticulars", string.IsNullOrEmpty(crPart) ? "Payment - " + crAcc : crPart);
                    cmd.Parameters.AddWithValue("@DRaccountcode", drAcc);
                    cmd.Parameters.AddWithValue("@DRaccounttype", drType);
                    cmd.Parameters.AddWithValue("@DRParticulars", string.IsNullOrEmpty(drPart) ? "Payment - " + drAcc : drPart);
                    cmd.Parameters.AddWithValue("@transaction_amount", amount);
                    cmd.Parameters.AddWithValue("@voucherNo", voucherNo);
                    cmd.Parameters.AddWithValue("@transactionDate", vDate);
                    cmd.Parameters.AddWithValue("@teller", user);
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Payment Voucher #" + voucherNo + " created successfully.", true);
                pnlCreate.Visible = false;
                txtAmount.Text = "";
                txtDRParticulars.Text = "";
                txtCRParticulars.Text = "";
                LoadVouchers();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void gvVouchers_FocusedRowChanged(object sender, EventArgs e)
    {
        if (gvVouchers.FocusedRowIndex >= 0)
        {
            object key = gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "VoucherNo");
            if (key != null)
            {
                int vno = Convert.ToInt32(key);
                LoadVoucherDetail(vno);
            }
        }
    }

    private void LoadVoucherDetail(int voucherNo)
    {
        pnlDetail.Visible = true;
        lblVoucherNo.Text = voucherNo.ToString();

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Get status
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT PostStatus FROM fin_vouchernumbers WHERE VoucherNo = @vno", conn))
            {
                cmd.Parameters.AddWithValue("@vno", voucherNo);
                object statusResult = cmd.ExecuteScalar();
                string status = statusResult != null ? statusResult.ToString() : "";
                lblVoucherStatus.Text = status;
                btnApproveVoucher.Visible = (status == "New");
            }

            // Get transactions
            DataTable dt = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT TID, accountcode, account_type, transactionType, transaction_amount, particulars, transactionDate 
                  FROM fin_voucher WHERE voucherNo = @vno ORDER BY TID", conn))
            {
                cmd.Parameters.AddWithValue("@vno", voucherNo);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
            gvVoucherTrans.DataSource = dt;
            gvVoucherTrans.DataBind();
        }
    }

    protected void btnApproveVoucher_Click(object sender, EventArgs e)
    {
        int vno = 0;
        int.TryParse(lblVoucherNo.Text, out vno);
        if (vno == 0) return;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("fin_ApproveVoucher", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@VNo", vno);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowMessage("Voucher #" + vno + " approved.", true);
            LoadVoucherDetail(vno);
            LoadVouchers();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnCloseDetail_Click(object sender, EventArgs e)
    {
        pnlDetail.Visible = false;
    }

    private string GetAccountType(MySqlConnection conn, string accountCode)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COALESCE(accounttype, '') FROM fin_subaccounts WHERE AccountCode = @acc", conn))
        {
            cmd.Parameters.AddWithValue("@acc", accountCode);
            object atResult = cmd.ExecuteScalar();
            return atResult != null ? atResult.ToString() : "";
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = "<div class='pv-msg " + (success ? "pv-msg--success" : "pv-msg--error") + "'>" + Server.HtmlEncode(msg) + "</div>";
    }
}
