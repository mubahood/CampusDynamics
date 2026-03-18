using System;
using System.Data;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_StudentReceipts : System.Web.UI.Page
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
            LoadAccountsCombos();
            LoadReceipts();
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

    protected void btnFilter_Click(object sender, EventArgs e) { LoadReceipts(); }

    private void LoadReceipts()
    {
        DateTime startDate, endDate;
        DateTime.TryParse(txtStartDate.Text, out startDate);
        DateTime.TryParse(txtEndDate.Text, out endDate);
        if (startDate == DateTime.MinValue) startDate = DateTime.Today.AddMonths(-1);
        if (endDate == DateTime.MinValue) endDate = DateTime.Today;

        string status = ddlStatus.SelectedValue;
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT VoucherNo, voucherDate, Teller, PostStatus 
                           FROM fin_vouchernumbers 
                           WHERE Vouchertype = 'Receipt' AND voucherDate BETWEEN @sDate AND @eDate";
            if (!string.IsNullOrEmpty(status))
                sql += " AND PostStatus = @status";
            sql += " ORDER BY VoucherNo DESC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sDate", startDate);
                cmd.Parameters.AddWithValue("@eDate", endDate);
                if (!string.IsNullOrEmpty(status))
                    cmd.Parameters.AddWithValue("@status", status);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        gvReceipts.DataSource = dt;
        gvReceipts.DataBind();
    }

    protected void btnNewReceipt_Click(object sender, EventArgs e) { pnlCreate.Visible = true; }
    protected void btnCancelCreate_Click(object sender, EventArgs e) { pnlCreate.Visible = false; }

    protected void btnConfirmCreate_Click(object sender, EventArgs e)
    {
        string drAcc = cboDRAccount.Value != null ? cboDRAccount.Value.ToString() : "";
        string crAcc = cboCRAccount.Value != null ? cboCRAccount.Value.ToString() : "";
        double amount = 0;
        double.TryParse(txtAmount.Text, out amount);
        string particulars = txtParticulars.Text.Trim();
        string admNo = txtAdmissionNo.Text.Trim();

        if (string.IsNullOrEmpty(drAcc) || string.IsNullOrEmpty(crAcc) || amount <= 0)
        {
            ShowMessage("Select accounts and enter valid amount.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                string drType = GetAccountType(conn, drAcc);
                string crType = GetAccountType(conn, crAcc);
                string user = HttpContext.Current.User.Identity.Name;
                string partText = string.IsNullOrEmpty(particulars) ? "Student Receipt - " + admNo : particulars;

                int voucherNo = 0;
                using (MySqlCommand cmd = new MySqlCommand("fin_GetLatestVoucherNo", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usr", user);
                    cmd.Parameters.AddWithValue("@typ", "Receipt");
                    cmd.Parameters.AddWithValue("@cat", "Receipt");
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read()) voucherNo = reader.GetInt32(0);
                    }
                }

                using (MySqlCommand cmd = new MySqlCommand("fin_VoucherCreator", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@vNo", voucherNo);
                    cmd.Parameters.AddWithValue("@CRaccountcode", crAcc);
                    cmd.Parameters.AddWithValue("@CRaccountType", crType);
                    cmd.Parameters.AddWithValue("@CRParticulars", partText);
                    cmd.Parameters.AddWithValue("@DRaccountcode", drAcc);
                    cmd.Parameters.AddWithValue("@DRaccounttype", drType);
                    cmd.Parameters.AddWithValue("@DRParticulars", partText);
                    cmd.Parameters.AddWithValue("@transaction_amount", amount);
                    cmd.Parameters.AddWithValue("@voucherNo", voucherNo);
                    cmd.Parameters.AddWithValue("@transactionDate", DateTime.Today);
                    cmd.Parameters.AddWithValue("@teller", user);
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Receipt #" + voucherNo + " created for student " + admNo + ".", true);
                pnlCreate.Visible = false;
                txtAmount.Text = "";
                txtParticulars.Text = "";
                txtAdmissionNo.Text = "";
                LoadReceipts();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void gvReceipts_FocusedRowChanged(object sender, EventArgs e)
    {
        if (gvReceipts.FocusedRowIndex >= 0)
        {
            object key = gvReceipts.GetRowValues(gvReceipts.FocusedRowIndex, "VoucherNo");
            if (key != null) LoadReceiptDetail(Convert.ToInt32(key));
        }
    }

    private void LoadReceiptDetail(int vno)
    {
        pnlDetail.Visible = true;
        lblReceiptNo.Text = vno.ToString();

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT PostStatus FROM fin_vouchernumbers WHERE VoucherNo = @vno", conn))
            {
                cmd.Parameters.AddWithValue("@vno", vno);
                object statusResult = cmd.ExecuteScalar();
                string status = statusResult != null ? statusResult.ToString() : "";
                lblReceiptStatus.Text = status;
                btnApproveReceipt.Visible = (status == "New");
            }

            DataTable dt = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT TID, accountcode, account_type, transactionType, transaction_amount, particulars 
                  FROM fin_voucher WHERE voucherNo = @vno ORDER BY TID", conn))
            {
                cmd.Parameters.AddWithValue("@vno", vno);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
            gvReceiptTrans.DataSource = dt;
            gvReceiptTrans.DataBind();
        }
    }

    protected void btnApproveReceipt_Click(object sender, EventArgs e)
    {
        int vno = 0;
        int.TryParse(lblReceiptNo.Text, out vno);
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
            ShowMessage("Receipt #" + vno + " approved.", true);
            LoadReceiptDetail(vno);
            LoadReceipts();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnCloseDetail_Click(object sender, EventArgs e) { pnlDetail.Visible = false; }

    private string GetAccountType(MySqlConnection conn, string accountCode)
    {
        using (MySqlCommand cmd = new MySqlCommand("SELECT COALESCE(accounttype,'') FROM fin_subaccounts WHERE AccountCode = @acc", conn))
        {
            cmd.Parameters.AddWithValue("@acc", accountCode);
            object atResult = cmd.ExecuteScalar();
            return atResult != null ? atResult.ToString() : "";
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = "<div class='sr-msg " + (success ? "sr-msg--success" : "sr-msg--error") + "'>" + Server.HtmlEncode(msg) + "</div>";
    }
}
