using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_BalanceSheet : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    private decimal _totalAssets = 0;
    private decimal _totalLiabilities = 0;
    private decimal _totalEquity = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAsAtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        LoadBalanceSheet();
    }

    private void LoadBalanceSheet()
    {
        DateTime asAtDate;
        if (!DateTime.TryParse(txtAsAtDate.Text, out asAtDate))
            asAtDate = DateTime.Today;

        // Balance sheet uses the same SP with start date far in past to capture all historical balances
        DateTime startDate = new DateTime(2000, 1, 1);

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("fin_BalanceSheet", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@sDate", startDate.ToString("yyyy-MM-dd"));
                cmd.Parameters.AddWithValue("@eDate", asAtDate.ToString("yyyy-MM-dd"));
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        // Get docHeader from first row if available
        string docHeader = "";
        if (dt.Rows.Count > 0 && dt.Columns.Contains("docHeader"))
        {
            docHeader = dt.Rows[0]["docHeader"].ToString();
        }

        // Separate into Assets, Liabilities, Equity based on header column
        DataTable dtAssets = dt.Clone();
        DataTable dtLiabilities = dt.Clone();
        DataTable dtEquity = dt.Clone();

        if (!dtAssets.Columns.Contains("Amount"))
        {
            dtAssets.Columns.Add("Amount", typeof(decimal));
            dtLiabilities.Columns.Add("Amount", typeof(decimal));
            dtEquity.Columns.Add("Amount", typeof(decimal));
        }

        foreach (DataRow row in dt.Rows)
        {
            string header = row.Table.Columns.Contains("header") ? row["header"].ToString().ToLower() : "";
            decimal dr = 0, cr = 0;
            decimal.TryParse(row["DRBalance"].ToString(), out dr);
            decimal.TryParse(row["CRBalance"].ToString(), out cr);

            if (header.Contains("asset"))
            {
                DataRow newRow = dtAssets.NewRow();
                foreach (DataColumn col in dt.Columns)
                    newRow[col.ColumnName] = row[col.ColumnName];
                newRow["Amount"] = dr - cr; // Assets have debit balance
                dtAssets.Rows.Add(newRow);
                _totalAssets += (dr - cr);
            }
            else if (header.Contains("liabilit"))
            {
                DataRow newRow = dtLiabilities.NewRow();
                foreach (DataColumn col in dt.Columns)
                    newRow[col.ColumnName] = row[col.ColumnName];
                newRow["Amount"] = cr - dr; // Liabilities have credit balance
                dtLiabilities.Rows.Add(newRow);
                _totalLiabilities += (cr - dr);
            }
            else if (header.Contains("equity") || header.Contains("capital") || header.Contains("retained"))
            {
                DataRow newRow = dtEquity.NewRow();
                foreach (DataColumn col in dt.Columns)
                    newRow[col.ColumnName] = row[col.ColumnName];
                newRow["Amount"] = cr - dr; // Equity has credit balance
                dtEquity.Rows.Add(newRow);
                _totalEquity += (cr - dr);
            }
            else
            {
                // Fallback: DR balance = Asset, CR balance = Liability
                if (dr >= cr)
                {
                    DataRow newRow = dtAssets.NewRow();
                    foreach (DataColumn col in dt.Columns)
                        newRow[col.ColumnName] = row[col.ColumnName];
                    newRow["Amount"] = dr - cr;
                    dtAssets.Rows.Add(newRow);
                    _totalAssets += (dr - cr);
                }
                else
                {
                    DataRow newRow = dtLiabilities.NewRow();
                    foreach (DataColumn col in dt.Columns)
                        newRow[col.ColumnName] = row[col.ColumnName];
                    newRow["Amount"] = cr - dr;
                    dtLiabilities.Rows.Add(newRow);
                    _totalLiabilities += (cr - dr);
                }
            }
        }

        rptAssets.DataSource = dtAssets;
        rptAssets.DataBind();

        rptLiabilities.DataSource = dtLiabilities;
        rptLiabilities.DataBind();

        rptEquity.DataSource = dtEquity;
        rptEquity.DataBind();

        // Set header info
        litDocHeader.Text = docHeader;
        litAsAtDate.Text = asAtDate.ToString("dd MMM yyyy");
        litGenDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");

        // Equation bar
        litEqAssets.Text = _totalAssets.ToString("N2");
        litEqLiabilities.Text = _totalLiabilities.ToString("N2");
        litEqEquity.Text = _totalEquity.ToString("N2");

        // Check balance: Assets = Liabilities + Equity
        decimal diff = Math.Abs(_totalAssets - (_totalLiabilities + _totalEquity));
        if (diff < 0.01m)
        {
            pnlBalanceStatus.CssClass = "bs-status-banner bs-status-ok";
            litBalanceStatus.Text = "&#10004; Balance Sheet is BALANCED — Assets = Liabilities + Equity.";
        }
        else
        {
            pnlBalanceStatus.CssClass = "bs-status-banner bs-status-err";
            litBalanceStatus.Text = "&#9888; Balance Sheet is UNBALANCED — Difference of " + diff.ToString("N2") + " detected.";
        }

        pnlReport.Visible = true;
    }

    protected void rptAssets_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalAssets") as Literal;
            if (lit != null) lit.Text = _totalAssets.ToString("N2");
        }
    }

    protected void rptLiabilities_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalLiabilities") as Literal;
            if (lit != null) lit.Text = _totalLiabilities.ToString("N2");
        }
    }

    protected void rptEquity_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalEquity") as Literal;
            if (lit != null) lit.Text = _totalEquity.ToString("N2");
        }
    }
}
