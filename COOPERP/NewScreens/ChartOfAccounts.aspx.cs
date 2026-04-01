using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_ChartOfAccounts : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadMainAccounts();
            LoadSubAccounts(null);
            LoadMainAccountDropdown();
            LoadFilterMainAccDropdown();
            LoadLedgerTypesDropdown();
            LoadStats();
        }
    }

    private void LoadStats()
    {
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT (SELECT COUNT(*) FROM fin_mainaccounts) AS main_cnt,"
              + " (SELECT COUNT(*) FROM fin_subaccounts) AS sub_cnt,"
              + " (SELECT COUNT(DISTINCT GeneralCategory) FROM fin_mainaccounts) AS cat_cnt,"
              + " (SELECT COUNT(*) FROM fin_ledgertypes) AS lt_cnt", conn))
            {
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litMainCount.Text = Convert.ToInt32(rdr["main_cnt"]).ToString("N0");
                        litSubCount.Text = Convert.ToInt32(rdr["sub_cnt"]).ToString("N0");
                        litCatCount.Text = Convert.ToInt32(rdr["cat_cnt"]).ToString("N0");
                        litLedgerTypes.Text = Convert.ToInt32(rdr["lt_cnt"]).ToString("N0");
                    }
                }
            }
        }
    }

    private void LoadMainAccounts()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT AccountCode, AccountName, GeneralCategory, SubCategory FROM fin_mainaccounts ORDER BY AccountCode", conn))
            {
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
            }
        }
        rptMainAccounts.DataSource = dt;
        rptMainAccounts.DataBind();
        phNoMain.Visible = (dt.Rows.Count == 0);
        litMainFooter.Text = string.Format("<strong>{0}</strong> main accounts", dt.Rows.Count);
        litMainBadge.Text = string.Format("<span class='ft-card__meta'>{0} accounts</span>", dt.Rows.Count);
    }

    private void LoadSubAccounts(string mainAccountCode)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = mainAccountCode != null
                ? "SELECT AccountCode, AccountName, MainAccountCode, Details, accounttype, collectionLedgerType FROM fin_subaccounts WHERE MainAccountCode = @mac ORDER BY AccountCode"
                : "SELECT AccountCode, AccountName, MainAccountCode, Details, accounttype, collectionLedgerType FROM fin_subaccounts ORDER BY AccountCode";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (mainAccountCode != null)
                    cmd.Parameters.AddWithValue("@mac", mainAccountCode);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
            }
        }
        rptSubAccounts.DataSource = dt;
        rptSubAccounts.DataBind();
        phNoSub.Visible = (dt.Rows.Count == 0);
        litSubFooter.Text = string.Format("<strong>{0}</strong> sub accounts", dt.Rows.Count);

        if (mainAccountCode != null)
            litSubBadge.Text = string.Format("<span class='ft-card__meta'>Filtered: {0}</span>", Server.HtmlEncode(mainAccountCode));
        else
            litSubBadge.Text = "<span class='ft-card__meta'>Showing all</span>";
    }

    private void LoadMainAccountDropdown()
    {
        ddlMainAccountForSub.Items.Clear();
        ddlMainAccountForSub.Items.Add(new ListItem("-- Select Main Account --", ""));

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT AccountCode, AccountName FROM fin_mainaccounts ORDER BY AccountCode", conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["AccountCode"].ToString();
                        string name = reader["AccountName"].ToString();
                        ddlMainAccountForSub.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }
    }

    private void LoadFilterMainAccDropdown()
    {
        ddlFilterMainAcc.Items.Clear();
        ddlFilterMainAcc.Items.Add(new ListItem("All Main Accounts", ""));

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT AccountCode, AccountName FROM fin_mainaccounts ORDER BY AccountCode", conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["AccountCode"].ToString();
                        string name = reader["AccountName"].ToString();
                        ddlFilterMainAcc.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }
    }

    private void LoadLedgerTypesDropdown()
    {
        ddlLedgerTypeForSub.Items.Clear();
        ddlLedgerTypeForSub.Items.Add(new ListItem("-- Select --", ""));

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT LedgerTypeName FROM fin_ledgertypes ORDER BY LedgerTypeName", conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name = reader["LedgerTypeName"].ToString();
                        ddlLedgerTypeForSub.Items.Add(new ListItem(name, name));
                    }
                }
            }
        }
    }

    protected void ddlFilterMainAcc_Changed(object sender, EventArgs e)
    {
        string val = ddlFilterMainAcc.SelectedValue;
        LoadSubAccounts(string.IsNullOrEmpty(val) ? null : val);
    }

    protected void btnAddMainAccount_Click(object sender, EventArgs e)
    {
        string code = txtMainAccCode.Text.Trim();
        string name = txtMainAccName.Text.Trim();
        string category = ddlGeneralCategory.SelectedValue;
        string subCat = txtSubCategory.Text.Trim();

        if (string.IsNullOrEmpty(code) || string.IsNullOrEmpty(name) || string.IsNullOrEmpty(category))
        {
            ShowMessage("Please fill in Account Code, Name, and Category.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("MainAccountEditor", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usr", HttpContext.Current.User.Identity.Name);
                    cmd.Parameters.AddWithValue("@AccCode", code);
                    cmd.Parameters.AddWithValue("@AccountName", name);
                    cmd.Parameters.AddWithValue("@GeneralCategory", category);
                    cmd.Parameters.AddWithValue("@SubCategory", subCat);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowMessage("Main account '" + code + "' added successfully.", true);
            txtMainAccCode.Text = "";
            txtMainAccName.Text = "";
            txtSubCategory.Text = "";
            LoadMainAccounts();
            LoadMainAccountDropdown();
            LoadFilterMainAccDropdown();
            LoadStats();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnAddSubAccount_Click(object sender, EventArgs e)
    {
        string mainAcc = ddlMainAccountForSub.SelectedValue;
        string name = txtSubAccName.Text.Trim();
        string details = txtSubAccDetails.Text.Trim();
        string accType = txtSubAccType.Text.Trim();
        string ledgerType = ddlLedgerTypeForSub.SelectedValue;

        if (string.IsNullOrEmpty(mainAcc) || string.IsNullOrEmpty(name))
        {
            ShowMessage("Please select a Main Account and enter Account Name.", false);
            return;
        }

        try
        {
            string newCode = "";
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT fin_NextAccountCode(@mainAcc) AS AccountCode FROM DUAL", conn))
                {
                    cmd.Parameters.AddWithValue("@mainAcc", mainAcc);
                    object codeResult = cmd.ExecuteScalar();
                    newCode = codeResult != null ? codeResult.ToString() : "";
                }

                if (string.IsNullOrEmpty(newCode))
                {
                    ShowMessage("Error generating account code.", false);
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand("AccountEditor", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usr", HttpContext.Current.User.Identity.Name);
                    cmd.Parameters.AddWithValue("@AccCode", newCode);
                    cmd.Parameters.AddWithValue("@MainAccountCode", mainAcc);
                    cmd.Parameters.AddWithValue("@AccountName", name);
                    cmd.Parameters.AddWithValue("@Details", details);
                    cmd.Parameters.AddWithValue("@accountType", accType);
                    cmd.Parameters.AddWithValue("@collectionLedgerType", ledgerType);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowMessage("Sub account '" + newCode + " - " + name + "' created successfully.", true);
            txtSubAccName.Text = "";
            txtSubAccDetails.Text = "";
            txtSubAccType.Text = "";
            LoadSubAccounts(mainAcc);
            LoadStats();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void rptMainAccounts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        string code = e.CommandArgument.ToString();
        if (e.CommandName == "ViewSubs")
        {
            ddlFilterMainAcc.SelectedValue = code;
            LoadSubAccounts(code);
        }
        else if (e.CommandName == "DeleteMain")
        {
            try
            {
                using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
                {
                    conn.Open();
                    using (MySqlCommand cmd = new MySqlCommand("DeleteMainAccount", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@usr", HttpContext.Current.User.Identity.Name);
                        cmd.Parameters.AddWithValue("@AccCode", code);
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMessage("Main account deleted.", true);
                LoadMainAccounts();
                LoadMainAccountDropdown();
                LoadFilterMainAccDropdown();
                LoadStats();
            }
            catch (Exception ex)
            {
                ShowMessage("Cannot delete: " + ex.Message, false);
            }
        }
    }

    protected void rptSubAccounts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "DeleteSub")
        {
            string code = e.CommandArgument.ToString();
            try
            {
                using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
                {
                    conn.Open();
                    using (MySqlCommand cmd = new MySqlCommand("DeleteAccount", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@usr", HttpContext.Current.User.Identity.Name);
                        cmd.Parameters.AddWithValue("@AccCode", code);
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMessage("Sub account deleted.", true);
                string filter = ddlFilterMainAcc.SelectedValue;
                LoadSubAccounts(string.IsNullOrEmpty(filter) ? null : filter);
                LoadStats();
            }
            catch (Exception ex)
            {
                ShowMessage("Cannot delete: " + ex.Message, false);
            }
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        string cssClass = success ? "ft-toast ft-toast--success" : "ft-toast ft-toast--error";
        lblMessage.Text = "<div class='" + cssClass + "'>" + Server.HtmlEncode(msg) + "</div>";
        lblMessage.Visible = true;
    }
}
