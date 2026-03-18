using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_IncomeStatement : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    private decimal _totalIncome = 0;
    private decimal _totalExpense = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = new DateTime(DateTime.Today.Year, 1, 1).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        LoadIncomeStatement();
    }

    private void LoadIncomeStatement()
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
            using (MySqlCommand cmd = new MySqlCommand("fin_IncomeStatement", conn))
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

        // Get docHeader from first row if available
        string docHeader = "";
        if (dt.Rows.Count > 0 && dt.Columns.Contains("docHeader"))
        {
            docHeader = dt.Rows[0]["docHeader"].ToString();
        }

        // Separate income and expense rows
        // Income: category = 'Income' or header contains 'Income/Revenue'
        // Expense: category = 'Expense' or header contains 'Expense'
        DataTable dtIncome = dt.Clone();
        DataTable dtExpense = dt.Clone();

        // Add computed Amount column
        if (!dtIncome.Columns.Contains("Amount"))
        {
            dtIncome.Columns.Add("Amount", typeof(decimal));
            dtExpense.Columns.Add("Amount", typeof(decimal));
        }

        foreach (DataRow row in dt.Rows)
        {
            string header = row.Table.Columns.Contains("header") ? row["header"].ToString().ToLower() : "";
            decimal dr = 0, cr = 0;
            decimal.TryParse(row["DRBalance"].ToString(), out dr);
            decimal.TryParse(row["CRBalance"].ToString(), out cr);

            // Income accounts: Credit balance typically (CR - DR)
            // Expense accounts: Debit balance typically (DR - CR)
            if (header.Contains("income") || header.Contains("revenue"))
            {
                DataRow newRow = dtIncome.NewRow();
                foreach (DataColumn col in dt.Columns)
                {
                    newRow[col.ColumnName] = row[col.ColumnName];
                }
                newRow["Amount"] = cr - dr; // net credit for income
                dtIncome.Rows.Add(newRow);
                _totalIncome += (cr - dr);
            }
            else if (header.Contains("expense") || header.Contains("cost"))
            {
                DataRow newRow = dtExpense.NewRow();
                foreach (DataColumn col in dt.Columns)
                {
                    newRow[col.ColumnName] = row[col.ColumnName];
                }
                newRow["Amount"] = dr - cr; // net debit for expenses
                dtExpense.Rows.Add(newRow);
                _totalExpense += (dr - cr);
            }
            else
            {
                // Default: if DR > CR treat as expense, otherwise income
                if (dr > cr)
                {
                    DataRow newRow = dtExpense.NewRow();
                    foreach (DataColumn col in dt.Columns)
                    {
                        newRow[col.ColumnName] = row[col.ColumnName];
                    }
                    newRow["Amount"] = dr - cr;
                    dtExpense.Rows.Add(newRow);
                    _totalExpense += (dr - cr);
                }
                else
                {
                    DataRow newRow = dtIncome.NewRow();
                    foreach (DataColumn col in dt.Columns)
                    {
                        newRow[col.ColumnName] = row[col.ColumnName];
                    }
                    newRow["Amount"] = cr - dr;
                    dtIncome.Rows.Add(newRow);
                    _totalIncome += (cr - dr);
                }
            }
        }

        rptIncome.DataSource = dtIncome;
        rptIncome.DataBind();

        rptExpense.DataSource = dtExpense;
        rptExpense.DataBind();

        // Set header literals
        litDocHeader.Text = docHeader;
        litPeriodStart.Text = startDate.ToString("dd MMM yyyy");
        litPeriodEnd.Text = endDate.ToString("dd MMM yyyy");
        litGenDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");

        // Set net income
        decimal netIncome = _totalIncome - _totalExpense;
        string netClass = netIncome >= 0 ? "is-net-positive" : "is-net-negative";
        litNetIncome.Text = "<span class='" + netClass + "'>" + netIncome.ToString("N2") + "</span>";

        // Summary bar
        litSumIncome.Text = _totalIncome.ToString("N2");
        litSumExpense.Text = _totalExpense.ToString("N2");
        litSumNet.Text = netIncome.ToString("N2");
        spanNetResult.Attributes["class"] = "is-summary-value " + netClass;

        pnlReport.Visible = true;
    }

    protected void rptIncome_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalIncome") as Literal;
            if (lit != null) lit.Text = _totalIncome.ToString("N2");
        }
    }

    protected void rptExpense_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalExpense") as Literal;
            if (lit != null) lit.Text = _totalExpense.ToString("N2");
        }
    }
}
