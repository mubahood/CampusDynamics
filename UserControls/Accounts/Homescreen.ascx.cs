using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

// G1: Financial dashboard replacing the blank Homescreen
public partial class UserControls_FrontOffice_Homescreen : System.Web.UI.UserControl
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            LoadDashboard();
    }

    private void LoadDashboard()
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                LoadPeriodBar(conn);
                LoadKpis(conn);
                LoadRecentTransactions(conn);
                LoadAlerts(conn);
            }
        }
        catch (Exception ex)
        {
            litAlerts.Text = "<div class='acc-empty' style='color:#dc3545'>Dashboard load error: " + ex.Message + "</div>";
        }
    }

    private void LoadPeriodBar(MySqlConnection conn)
    {
        string sql = "SELECT period_name, start_date, end_date, status FROM fin_financial_years ORDER BY FIELD(status,'Open','Closed') LIMIT 1";
        using (var cmd = new MySqlCommand(sql, conn))
        using (var dr = cmd.ExecuteReader())
        {
            if (dr.Read())
            {
                string status = dr["status"].ToString();
                string color = status == "Open" ? "#28a745" : "#dc3545";
                divPeriodBar.InnerHtml = string.Format(
                    "Financial Period: <span>{0}</span> &nbsp;|&nbsp; {1} – {2} &nbsp;|&nbsp; " +
                    "<span style='color:{3};font-weight:700'>{4}</span>",
                    dr["period_name"],
                    Convert.ToDateTime(dr["start_date"]).ToString("dd MMM yyyy"),
                    Convert.ToDateTime(dr["end_date"]).ToString("dd MMM yyyy"),
                    color, status.ToUpper());
            }
            else
            {
                divPeriodBar.InnerHtml = "<span style='color:#dc3545'>⚠ No financial period configured</span>";
            }
        }
    }

    private void LoadKpis(MySqlConnection conn)
    {
        // Pending journals
        string sqlPending = "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus = 'Pending'";
        litPending.Text = ExecuteScalar(conn, sqlPending, "0");

        // Unbalanced vouchers in repair log awaiting review
        string sqlUnbal = "SELECT COUNT(*) FROM fin_repair_log WHERE repair_type = 'UNBALANCED_VOUCHER' AND action_taken = 'PENDING_REVIEW'";
        litUnbalanced.Text = ExecuteScalar(conn, sqlUnbal, "0");

        // Total DR and CR for the current open year
        string sqlTotals = @"
            SELECT
                SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END) AS total_dr,
                SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END) AS total_cr
            FROM fin_ledger l
            JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
            WHERE j.PostStatus = 'Posted'
              AND l.transactionDate >= (SELECT MIN(start_date) FROM fin_financial_years WHERE status = 'Open')
              AND l.transactionDate <= (SELECT MAX(end_date)   FROM fin_financial_years WHERE status = 'Open')";

        using (var cmd = new MySqlCommand(sqlTotals, conn))
        using (var dr = cmd.ExecuteReader())
        {
            if (dr.Read() && dr["total_dr"] != DBNull.Value)
            {
                litTotalDR.Text = FormatUgx(Convert.ToDecimal(dr["total_dr"]));
                litTotalCR.Text = FormatUgx(Convert.ToDecimal(dr["total_cr"]));
            }
            else
            {
                litTotalDR.Text = "UGX 0";
                litTotalCR.Text = "UGX 0";
            }
        }
    }

    private void LoadRecentTransactions(MySqlConnection conn)
    {
        string sql = @"
            SELECT l.TID, l.transactionDate, l.accountcode, l.transactionType,
                   l.transaction_amount, l.particulars, j.PostStatus, j.journalType
            FROM fin_ledger l
            LEFT JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
            ORDER BY l.TID DESC
            LIMIT 15";

        var sb = new StringBuilder();
        sb.Append("<table class='acc-mini-table'>");
        sb.Append("<tr><th>Date</th><th>Account</th><th>Type</th><th>Amount (UGX)</th><th>Particulars</th><th>Status</th></tr>");

        int rows = 0;
        using (var cmd = new MySqlCommand(sql, conn))
        using (var dr = cmd.ExecuteReader())
        {
            while (dr.Read())
            {
                rows++;
                string txType = dr["transactionType"].ToString();
                string status = dr["PostStatus"].ToString();
                string typeTag = txType == "DR"
                    ? "<span class='tag-dr'>DR</span>"
                    : "<span class='tag-cr'>CR</span>";
                string statusTag = status == "Posted"
                    ? "<span class='tag-posted'>Posted</span>"
                    : "<span class='tag-pending'>" + HttpUtility.HtmlEncode(status) + "</span>";
                string particulars = dr["particulars"].ToString();
                if (particulars.Length > 35) particulars = particulars.Substring(0, 35) + "…";

                sb.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td style='text-align:right'>{3}</td><td>{4}</td><td>{5}</td></tr>",
                    Convert.ToDateTime(dr["transactionDate"]).ToString("dd/MM/yy"),
                    HttpUtility.HtmlEncode(dr["accountcode"].ToString()),
                    typeTag,
                    string.Format("{0:N0}", Convert.ToDecimal(dr["transaction_amount"])),
                    HttpUtility.HtmlEncode(particulars),
                    statusTag);
            }
        }

        if (rows == 0)
            sb.Append("<tr><td colspan='6' class='acc-empty'>No transactions found</td></tr>");

        sb.Append("</table>");
        litRecentTxn.Text = sb.ToString();
    }

    private void LoadAlerts(MySqlConnection conn)
    {
        var sb = new StringBuilder();

        // Pending approvals
        int pending = int.Parse(ExecuteScalar(conn, "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus='Pending'", "0"));
        string pendingBadge = pending > 0
            ? string.Format("<span class='acc-badge badge-warn'>{0}</span>", pending)
            : "<span class='acc-badge badge-ok'>0</span>";
        sb.AppendFormat("<div class='acc-alert-item'><span>Journals pending approval</span>{0}</div>", pendingBadge);

        // Unbalanced vouchers
        int unbalanced = int.Parse(ExecuteScalar(conn, "SELECT COUNT(*) FROM fin_repair_log WHERE repair_type='UNBALANCED_VOUCHER' AND action_taken='PENDING_REVIEW'", "0"));
        string unbalBadge = unbalanced > 0
            ? string.Format("<span class='acc-badge'>{0}</span>", unbalanced)
            : "<span class='acc-badge badge-ok'>0</span>";
        sb.AppendFormat("<div class='acc-alert-item'><span>Unbalanced vouchers</span>{0}</div>", unbalBadge);

        // Voided journals count
        int voided = int.Parse(ExecuteScalar(conn, "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus='Void'", "0"));
        sb.AppendFormat("<div class='acc-alert-item'><span>Voided journals</span><span class='acc-badge badge-ok'>{0}</span></div>", voided);

        // Zero-amount entries
        int zeroAmt = int.Parse(ExecuteScalar(conn, "SELECT COUNT(*) FROM fin_ledger WHERE transaction_amount=0", "0"));
        string zeroAmtBadge = zeroAmt > 0
            ? string.Format("<span class='acc-badge badge-warn'>{0}</span>", zeroAmt)
            : "<span class='acc-badge badge-ok'>0</span>";
        sb.AppendFormat("<div class='acc-alert-item'><span>Zero-amount entries</span>{0}</div>", zeroAmtBadge);

        // Recent audit events today
        int todayLogs = int.Parse(ExecuteScalar(conn, "SELECT COUNT(*) FROM acc_activity_log WHERE DATE(access_date)=CURDATE()", "0"));
        sb.AppendFormat("<div class='acc-alert-item'><span>Audit events today</span><span class='acc-badge badge-ok'>{0}</span></div>", todayLogs);

        litAlerts.Text = sb.ToString();
    }

    private string ExecuteScalar(MySqlConnection conn, string sql, string fallback)
    {
        try
        {
            using (var cmd = new MySqlCommand(sql, conn))
            {
                object result = cmd.ExecuteScalar();
                return (result == null || result == DBNull.Value) ? fallback : result.ToString();
            }
        }
        catch { return fallback; }
    }

    private string FormatUgx(decimal amount)
    {
        if (amount >= 1_000_000_000m)
            return string.Format("UGX {0:N1}B", amount / 1_000_000_000m);
        if (amount >= 1_000_000m)
            return string.Format("UGX {0:N1}M", amount / 1_000_000m);
        return string.Format("UGX {0:N0}", amount);
    }
}
