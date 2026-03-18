using System;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_GeneralLedger : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Default dates: start of current month to today
            txtStartDate.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            LoadAccountsCombo();
            LoadLedger();
        }
    }

    private void LoadAccountsCombo()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT AccountCode, AccountName FROM fin_subaccounts ORDER BY AccountCode", conn))
            {
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        cboAccount.DataSource = dt;
        cboAccount.DataBind();
        cboAccount.Items.Insert(0, new DevExpress.Web.ListEditItem("All Accounts", ""));
    }

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadLedger();
    }

    private void LoadLedger()
    {
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
            startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
            endDate = DateTime.Today;

        string accountCode = cboAccount.Value != null ? cboAccount.Value.ToString() : "";
        string transType = ddlType.SelectedValue;

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT TID, transactionDate, accountcode, account_type, particulars, 
                                  transactionType, transaction_amount, voucherNo, teller 
                           FROM fin_ledger 
                           WHERE transactionDate BETWEEN @sDate AND @eDate";
            
            if (!string.IsNullOrEmpty(accountCode))
                sql += " AND accountcode = @acc";
            if (!string.IsNullOrEmpty(transType))
                sql += " AND transactionType = @typ";
            
            sql += " ORDER BY transactionDate DESC, TID DESC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sDate", startDate);
                cmd.Parameters.AddWithValue("@eDate", endDate);
                if (!string.IsNullOrEmpty(accountCode))
                    cmd.Parameters.AddWithValue("@acc", accountCode);
                if (!string.IsNullOrEmpty(transType))
                    cmd.Parameters.AddWithValue("@typ", transType);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        gvLedger.DataSource = dt;
        gvLedger.DataBind();

        // Update summary
        double totalDR = 0, totalCR = 0;
        foreach (DataRow row in dt.Rows)
        {
            double amt = Convert.ToDouble(row["transaction_amount"]);
            if (row["transactionType"].ToString() == "DR")
                totalDR += amt;
            else
                totalCR += amt;
        }
        lblSumDR.Text = totalDR.ToString("N0");
        lblSumCR.Text = totalCR.ToString("N0");
        lblRecordCount.Text = dt.Rows.Count.ToString("N0");
        lblLedgerTitle.Text = string.Format("({0:dd MMM yyyy} to {1:dd MMM yyyy})", startDate, endDate);
    }
}
