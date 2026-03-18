using System;
using System.Data;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_ContraVouchers : System.Web.UI.Page
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
            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            LoadAccounts();
            LoadContras();
        }
    }

    private void LoadAccounts()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT AccountCode, AccountName FROM fin_subaccounts ORDER BY AccountCode", conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                da.Fill(dt);
        }
        cboFromAccount.DataSource = dt;
        cboFromAccount.DataBind();
        cboToAccount.DataSource = dt;
        cboToAccount.DataBind();
    }

    protected void btnFilter_Click(object sender, EventArgs e) { LoadContras(); }

    private void LoadContras()
    {
        DateTime s, en;
        DateTime.TryParse(txtStartDate.Text, out s);
        DateTime.TryParse(txtEndDate.Text, out en);
        if (s == DateTime.MinValue) s = DateTime.Today.AddMonths(-1);
        if (en == DateTime.MinValue) en = DateTime.Today;

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT VoucherNo, voucherDate, Teller, PostStatus 
                  FROM fin_vouchernumbers 
                  WHERE Vouchertype = 'Contra' AND voucherDate BETWEEN @sDate AND @eDate 
                  ORDER BY VoucherNo DESC", conn))
            {
                cmd.Parameters.AddWithValue("@sDate", s);
                cmd.Parameters.AddWithValue("@eDate", en);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        gvContras.DataSource = dt;
        gvContras.DataBind();
    }

    protected void btnNewContra_Click(object sender, EventArgs e) { pnlCreate.Visible = true; }
    protected void btnCancelCreate_Click(object sender, EventArgs e) { pnlCreate.Visible = false; }

    protected void btnConfirmCreate_Click(object sender, EventArgs e)
    {
        string fromAcc = cboFromAccount.Value != null ? cboFromAccount.Value.ToString() : "";
        string toAcc = cboToAccount.Value != null ? cboToAccount.Value.ToString() : "";
        double amount = 0;
        double.TryParse(txtAmount.Text, out amount);
        string particulars = txtParticulars.Text.Trim();
        DateTime vDate;
        DateTime.TryParse(txtDate.Text, out vDate);
        if (vDate == DateTime.MinValue) vDate = DateTime.Today;

        if (string.IsNullOrEmpty(fromAcc) || string.IsNullOrEmpty(toAcc) || amount <= 0)
        {
            ShowMessage("Select both accounts and enter valid amount.", false);
            return;
        }
        if (fromAcc == toAcc)
        {
            ShowMessage("From and To accounts cannot be the same.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                string fromType = GetAccountType(conn, fromAcc);
                string toType = GetAccountType(conn, toAcc);
                string user = HttpContext.Current.User.Identity.Name;
                string part = string.IsNullOrEmpty(particulars) ? "Contra: " + fromAcc + " → " + toAcc : particulars;

                // Get voucher number
                int vNo = 0;
                using (MySqlCommand cmd = new MySqlCommand("fin_GetLatestVoucherNo", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usr", user);
                    cmd.Parameters.AddWithValue("@typ", "Contra");
                    cmd.Parameters.AddWithValue("@cat", "Contra");
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read()) vNo = reader.GetInt32(0);
                    }
                }

                using (MySqlCommand cmd = new MySqlCommand("fin_TransactionCreator", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CRaccountcode", fromAcc);
                    cmd.Parameters.AddWithValue("@CRaccountType", fromType);
                    cmd.Parameters.AddWithValue("@CRParticulars", part);
                    cmd.Parameters.AddWithValue("@DRaccountcode", toAcc);
                    cmd.Parameters.AddWithValue("@DRaccountType", toType);
                    cmd.Parameters.AddWithValue("@DRParticulars", part);
                    cmd.Parameters.AddWithValue("@transaction_amount", amount);
                    cmd.Parameters.AddWithValue("@voucherNo", vNo);
                    cmd.Parameters.AddWithValue("@transactionDate", vDate);
                    cmd.Parameters.AddWithValue("@teller", user);
                    cmd.Parameters.AddWithValue("@curr", "");
                    cmd.Parameters.AddWithValue("@folio", "Contra Voucher");
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Contra voucher created: " + fromAcc + " → " + toAcc + " (" + amount.ToString("N0") + ")", true);
                pnlCreate.Visible = false;
                txtAmount.Text = "";
                txtParticulars.Text = "";
                LoadContras();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    private string GetAccountType(MySqlConnection conn, string acc)
    {
        using (MySqlCommand cmd = new MySqlCommand("SELECT COALESCE(accounttype,'') FROM fin_subaccounts WHERE AccountCode=@a", conn))
        {
            cmd.Parameters.AddWithValue("@a", acc);
            object atResult = cmd.ExecuteScalar();
            return atResult != null ? atResult.ToString() : "";
        }
    }

    private void ShowMessage(string msg, bool ok)
    {
        lblMessage.Text = "<div class='cv-msg " + (ok ? "cv-msg--success" : "cv-msg--error") + "'>" + Server.HtmlEncode(msg) + "</div>";
    }
}
