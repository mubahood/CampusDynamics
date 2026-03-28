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
                string periodLabel = "";
                LoadPeriodDates(conn, ref periodStart, ref periodEnd, ref periodLabel);

                // Period badge in header
                if (!string.IsNullOrEmpty(periodLabel))
                    litPeriodBadge.Text = "<span class='fs-badge fs-badge--green' style='font-size:10px;padding:4px 10px;'>" +
                        Server.HtmlEncode(periodLabel) + " &bull; Open</span>";

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

                // 7. Recent Journals (full HTML table)
                LoadRecentJournals(conn);
            }
            catch (Exception ex)
            {
                litAlerts.Text = "<div class='fn-alert fn-alert--danger'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>" +
                    "Error loading dashboard: " + Server.HtmlEncode(ex.Message) + "</div>";
            }
        }
    }

    private void LoadPeriodDates(MySqlConnection conn, ref DateTime start, ref DateTime end, ref string label)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT finacial_Year, start_date, end_date FROM fin_financial_years WHERE status = 'Open' ORDER BY start_date DESC LIMIT 1", conn))
        {
            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    start = reader.GetDateTime("start_date");
                    end = reader.GetDateTime("end_date");
                    label = reader.GetString("finacial_Year");
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
                sb.AppendFormat("<div class='fn-alert fn-alert--danger'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>" +
                    "<strong>{0}</strong> unbalanced voucher(s) detected in the ledger.</div>", unbalanced);
            }
        }

        // Check for unposted journals
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus = 'New'", conn))
        {
            int pending = Convert.ToInt32(cmd.ExecuteScalar());
            if (pending > 0)
            {
                sb.AppendFormat("<div class='fn-alert fn-alert--warning'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'/><line x1='12' y1='9' x2='12' y2='13'/><line x1='12' y1='17' x2='12.01' y2='17'/></svg>" +
                    "<strong>{0}</strong> journal(s) pending approval/posting.</div>", pending);
            }
        }

        // Check open financial periods
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM fin_financial_years WHERE status = 'Open'", conn))
        {
            int openPeriods = Convert.ToInt32(cmd.ExecuteScalar());
            if (openPeriods == 0)
            {
                sb.Append("<div class='fn-alert fn-alert--danger'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>" +
                    "No open financial period! Transactions cannot be posted.</div>");
            }
            else if (openPeriods > 1)
            {
                sb.AppendFormat("<div class='fn-alert fn-alert--warning'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'/><line x1='12' y1='9' x2='12' y2='13'/><line x1='12' y1='17' x2='12.01' y2='17'/></svg>" +
                    "<strong>{0}</strong> financial periods are currently open. Consider closing older periods.</div>", openPeriods);
            }
            else
            {
                sb.Append("<div class='fn-alert fn-alert--info'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>" +
                    "Financial period is active and open.</div>");
            }
        }

        if (sb.Length == 0)
        {
            sb.Append("<div class='fn-alert fn-alert--info'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>" +
                "All systems normal. No alerts at this time.</div>");
        }

        litAlerts.Text = sb.ToString();
    }

    private void LoadRecentJournals(MySqlConnection conn)
    {
        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(
            @"SELECT j.JournalNo, j.journalType, j.journalDate, j.RefNo, j.journalParticulars, 
                     j.GL_VoucherNo, j.Teller, j.PostStatus,
                     COALESCE(SUM(CASE WHEN d.transactionType='DR' THEN d.transaction_amount ELSE 0 END),0) AS TotalDR,
                     COALESCE(SUM(CASE WHEN d.transactionType='CR' THEN d.transaction_amount ELSE 0 END),0) AS TotalCR
              FROM fin_journalnumbers j
              LEFT JOIN fin_journal_details d ON j.JournalNo = d.journal_no
              GROUP BY j.JournalNo
              ORDER BY j.JournalNo DESC 
              LIMIT 20", conn))
        {
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }

        litJournalCount.Text = dt.Rows.Count + " journals shown";

        StringBuilder sb = new StringBuilder();
        foreach (DataRow r in dt.Rows)
        {
            string status = r["PostStatus"].ToString();
            string badgeCls = status == "Approved" ? "fs-badge--green" : "fs-badge--amber";
            string jDate = r["journalDate"] != DBNull.Value
                ? Convert.ToDateTime(r["journalDate"]).ToString("dd MMM yyyy") : "—";
            double dr = r["TotalDR"] != DBNull.Value ? Convert.ToDouble(r["TotalDR"]) : 0;
            double cr = r["TotalCR"] != DBNull.Value ? Convert.ToDouble(r["TotalCR"]) : 0;

            sb.Append("<tr>");
            sb.AppendFormat("<td style='font-weight:600;color:#05275C;'>{0}</td>", Server.HtmlEncode(r["JournalNo"].ToString()));
            sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(r["journalType"].ToString()));
            sb.AppendFormat("<td>{0}</td>", jDate);
            sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(r["RefNo"].ToString()));
            sb.AppendFormat("<td style='max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>{0}</td>",
                Server.HtmlEncode(r["journalParticulars"].ToString()));
            sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(r["GL_VoucherNo"].ToString()));
            sb.AppendFormat("<td style='text-align:right;font-family:Consolas,monospace;font-size:10px;'>{0:N0}</td>", dr);
            sb.AppendFormat("<td style='text-align:right;font-family:Consolas,monospace;font-size:10px;'>{0:N0}</td>", cr);
            sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(r["Teller"].ToString()));
            sb.AppendFormat("<td><span class='fs-badge {0}'>{1}</span></td>", badgeCls, Server.HtmlEncode(status));
            sb.Append("</tr>");
        }

        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='10' style='text-align:center;padding:24px;color:#999;font-size:12px;'>No journal entries found.</td></tr>");
        }

        litRecentJournalRows.Text = sb.ToString();
    }
}
