using System;
using System.Data;
using System.Text;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_FinanceDashboard : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDashboard();
        }
    }

    private void LoadDashboard()
    {
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            try
            {
                conn.Open();

                // 1. Get current open financial period dates
                DateTime periodStart = DateTime.Today.AddMonths(-12);
                DateTime periodEnd = DateTime.Today;
                LoadPeriodDates(conn, ref periodStart, ref periodEnd);

                // 2. Total DR and CR for current period
                LoadPeriodTotals(conn, periodStart, periodEnd);

                // 3. Unposted journals count
                LoadUnpostedJournals(conn);

                // 4. Total accounts
                LoadAccountCount(conn);

                // 5. Financial periods list
                LoadFinancialPeriods(conn);

                // 6. Alerts
                LoadAlerts(conn);

                // 7. Recent Journals
                LoadRecentJournals(conn);
            }
            catch (Exception ex)
            {
                litAlerts.Text = "<div class='fin-alert fin-alert--danger'>Error loading dashboard: " + Server.HtmlEncode(ex.Message) + "</div>";
            }
        }
    }

    private void LoadPeriodDates(MySqlConnection conn, ref DateTime start, ref DateTime end)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT start_date, end_date FROM fin_financial_years WHERE status = 'Open' ORDER BY start_date DESC LIMIT 1", conn))
        {
            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    start = reader.GetDateTime("start_date");
                    end = reader.GetDateTime("end_date");
                }
            }
        }
    }

    private void LoadPeriodTotals(MySqlConnection conn, DateTime start, DateTime end)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            @"SELECT 
                COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0) AS TotalDR,
                COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0) AS TotalCR
              FROM fin_ledger 
              WHERE transactionDate BETWEEN @sDate AND @eDate", conn))
        {
            cmd.Parameters.AddWithValue("@sDate", start);
            cmd.Parameters.AddWithValue("@eDate", end);
            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    lblTotalDR.Text = String.Format("{0:N0}", reader.GetDouble("TotalDR"));
                    lblTotalCR.Text = String.Format("{0:N0}", reader.GetDouble("TotalCR"));
                }
            }
        }
    }

    private void LoadUnpostedJournals(MySqlConnection conn)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus = 'New'", conn))
        {
            int count = Convert.ToInt32(cmd.ExecuteScalar());
            lblUnpostedJournals.Text = count.ToString("N0");
        }
    }

    private void LoadAccountCount(MySqlConnection conn)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM fin_subaccounts", conn))
        {
            int count = Convert.ToInt32(cmd.ExecuteScalar());
            lblTotalAccounts.Text = count.ToString("N0");
        }
    }

    private void LoadFinancialPeriods(MySqlConnection conn)
    {
        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT finacial_Year, start_date, end_date, status FROM fin_financial_years ORDER BY start_date DESC LIMIT 5", conn))
        {
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        rptPeriods.DataSource = dt;
        rptPeriods.DataBind();
    }

    private void LoadAlerts(MySqlConnection conn)
    {
        StringBuilder sb = new StringBuilder();

        // Check for unbalanced vouchers
        using (MySqlCommand cmd = new MySqlCommand(
            @"SELECT COUNT(*) FROM (
                SELECT voucherNo FROM fin_ledger 
                GROUP BY voucherNo 
                HAVING ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END) 
                         - SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END)) > 0.01
              ) t", conn))
        {
            int unbalanced = Convert.ToInt32(cmd.ExecuteScalar());
            if (unbalanced > 0)
            {
                sb.AppendFormat("<div class='fin-alert fin-alert--danger'><strong>{0}</strong> unbalanced voucher(s) detected in the ledger.</div>", unbalanced);
            }
        }

        // Check for unposted journals
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus = 'New'", conn))
        {
            int pending = Convert.ToInt32(cmd.ExecuteScalar());
            if (pending > 0)
            {
                sb.AppendFormat("<div class='fin-alert fin-alert--warning'><strong>{0}</strong> journal(s) pending approval/posting.</div>", pending);
            }
        }

        // Check open financial periods
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM fin_financial_years WHERE status = 'Open'", conn))
        {
            int openPeriods = Convert.ToInt32(cmd.ExecuteScalar());
            if (openPeriods == 0)
            {
                sb.Append("<div class='fin-alert fin-alert--danger'>No open financial period! Transactions cannot be posted.</div>");
            }
            else if (openPeriods > 1)
            {
                sb.AppendFormat("<div class='fin-alert fin-alert--warning'><strong>{0}</strong> financial periods are currently open. Consider closing older periods.</div>", openPeriods);
            }
            else
            {
                sb.Append("<div class='fin-alert fin-alert--info'>Financial period is active and open.</div>");
            }
        }

        if (sb.Length == 0)
        {
            sb.Append("<div class='fin-alert fin-alert--info'>All systems normal. No alerts at this time.</div>");
        }

        litAlerts.Text = sb.ToString();
    }

    private void LoadRecentJournals(MySqlConnection conn)
    {
        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(
            @"SELECT JournalNo, journalType, journalDate, RefNo, journalParticulars, 
                     GL_VoucherNo, Teller, PostStatus 
              FROM fin_journalnumbers 
              ORDER BY JournalNo DESC 
              LIMIT 20", conn))
        {
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        gvRecentJournals.DataSource = dt;
        gvRecentJournals.DataBind();
    }
}
