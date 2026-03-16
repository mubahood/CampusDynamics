using System;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_accounts_TxnSearch : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string q = (Request.QueryString["q"] ?? "").Trim();
        litQuery.Text = HttpUtility.HtmlEncode(q);

        if (string.IsNullOrWhiteSpace(q))
        {
            litResults.Text = "<p class='empty'>Enter a voucher number, account code, student ID, or description.</p>";
            return;
        }

        // Accept numeric voucher no or free-text search
        string connStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString;
        var sb = new StringBuilder();
        sb.Append("<table><tr><th>Voucher No</th><th>Date</th><th>Account</th><th>DR/CR</th><th>Amount</th><th>Particulars</th><th>Status</th></tr>");

        string sql = @"
            SELECT l.voucherNo, l.transactionDate, l.accountcode, l.transactionType,
                   l.transaction_amount, l.particulars, j.PostStatus
            FROM fin_ledger l
            LEFT JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
            WHERE l.voucherNo = @qNum
               OR l.accountcode LIKE @qLike
               OR l.particulars  LIKE @qLike
            ORDER BY l.voucherNo DESC, l.TID DESC
            LIMIT 100";

        int qNum = 0;
        int.TryParse(q, out qNum);

        int rows = 0;
        try
        {
            using (var conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@qNum", qNum);
                    cmd.Parameters.AddWithValue("@qLike", "%" + q + "%");
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            rows++;
                            string txType = dr["transactionType"].ToString();
                            string status = dr["PostStatus"].ToString();
                            string typeTag   = txType == "DR" ? "<span class='tag-dr'>DR</span>" : "<span class='tag-cr'>CR</span>";
                            string statusTag = status == "Posted"
                                ? "<span class='tag-pos'>Posted</span>"
                                : "<span class='tag-pen'>" + HttpUtility.HtmlEncode(status) + "</span>";
                            string vno = dr["voucherNo"].ToString();
                            string particulars = dr["particulars"].ToString();
                            if (particulars.Length > 40) particulars = particulars.Substring(0, 40) + "…";

                            sb.AppendFormat(
                                "<tr><td><a href='TransactionDetails.aspx?vno={0}' target='_blank'>{0}</a></td>" +
                                "<td>{1}</td><td>{2}</td><td>{3}</td>" +
                                "<td style='text-align:right'>{4:N0}</td><td>{5}</td><td>{6}</td></tr>",
                                vno,
                                Convert.ToDateTime(dr["transactionDate"]).ToString("dd/MM/yy"),
                                HttpUtility.HtmlEncode(dr["accountcode"].ToString()),
                                typeTag,
                                Convert.ToDecimal(dr["transaction_amount"]),
                                HttpUtility.HtmlEncode(particulars),
                                statusTag);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            sb.Append("<tr><td colspan='7' class='empty'>Search error: " + HttpUtility.HtmlEncode(ex.Message) + "</td></tr>");
        }

        if (rows == 0)
            sb.Append("<tr><td colspan='7' class='empty'>No results found for &ldquo;" + HttpUtility.HtmlEncode(q) + "&rdquo;</td></tr>");

        sb.Append("</table>");
        if (rows > 0)
            sb.Insert(0, string.Format("<p class='qbar'>{0} result(s) found.</p>", rows));

        litResults.Text = sb.ToString();
    }
}
