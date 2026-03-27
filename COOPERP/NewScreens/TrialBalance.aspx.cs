using System;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_TrialBalance : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Default: current financial year
            txtStartDate.Text = new DateTime(DateTime.Today.Year, 1, 1).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        LoadTrialBalance();
    }

    private void LoadTrialBalance()
    {
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
            startDate = new DateTime(DateTime.Today.Year, 1, 1);
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
            endDate = DateTime.Today;

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("fin_TrialBalance", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@sDate", startDate.ToString("yyyy-MM-dd"));
                cmd.Parameters.AddWithValue("@eDate", endDate.ToString("yyyy-MM-dd"));
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        gridTrialBalance.DataSource = dt;
        gridTrialBalance.DataBind();

        // Compute totals
        decimal totalDR = 0, totalCR = 0;
        foreach (DataRow row in dt.Rows)
        {
            decimal dr = 0, cr = 0;
            decimal.TryParse(row["DRBalance"].ToString(), out dr);
            decimal.TryParse(row["CRBalance"].ToString(), out cr);
            totalDR += dr;
            totalCR += cr;
        }

        decimal diff = Math.Abs(totalDR - totalCR);

        litTotalDR.Text = totalDR.ToString("N2");
        litTotalCR.Text = totalCR.ToString("N2");
        litDifference.Text = diff.ToString("N2");
        litAccountCount.Text = dt.Rows.Count.ToString();

        litPeriodStart.Text = startDate.ToString("dd MMM yyyy");
        litPeriodEnd.Text = endDate.ToString("dd MMM yyyy");
        litGenDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");

        // Balance status
        if (diff < 0.01m)
        {
            pnlBalanceStatus.CssClass = "tb-status-banner tb-status-ok";
            litBalanceStatus.Text = "&#10004; Trial Balance is BALANCED - Total Debits equal Total Credits.";
            spanDiff.Attributes["class"] = "tb-summary-value tb-balanced";
        }
        else
        {
            pnlBalanceStatus.CssClass = "tb-status-banner tb-status-err";
            litBalanceStatus.Text = "&#9888; Trial Balance is UNBALANCED - Difference of " + diff.ToString("N2") + " detected.";
            spanDiff.Attributes["class"] = "tb-summary-value tb-unbalanced";
        }

        pnlReport.Visible = true;
    }
}
