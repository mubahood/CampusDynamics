using System;
using System.Data;
using System.Web;
using System.Web.UI;
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
            LoadLedgerTypesDropdown();
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
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        gvMainAccounts.DataSource = dt;
        gvMainAccounts.DataBind();
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
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        gvSubAccounts.DataSource = dt;
        gvSubAccounts.DataBind();
        
        if (mainAccountCode != null)
            spanSelectedMain.InnerText = "(filtered by: " + mainAccountCode + ")";
        else
            spanSelectedMain.InnerText = "(showing all)";
    }

    private void LoadMainAccountDropdown()
    {
        ddlMainAccountForSub.Items.Clear();
        ddlMainAccountForSub.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Main Account --", ""));
        
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
                        ddlMainAccountForSub.Items.Add(new System.Web.UI.WebControls.ListItem(
                            code + " - " + name, code));
                    }
                }
            }
        }
    }

    private void LoadLedgerTypesDropdown()
    {
        ddlLedgerTypeForSub.Items.Clear();
        ddlLedgerTypeForSub.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select --", ""));
        
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
                        ddlLedgerTypeForSub.Items.Add(new System.Web.UI.WebControls.ListItem(name, name));
                    }
                }
            }
        }
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
            // Get next account code
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
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void gvMainAccounts_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        e.Cancel = true;
        string code = e.Keys["AccountCode"].ToString();

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
        }
        catch (Exception ex)
        {
            ShowMessage("Cannot delete: " + ex.Message, false);
        }
    }

    protected void gvSubAccounts_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        e.Cancel = true;
        string code = e.Keys["AccountCode"].ToString();

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
            LoadSubAccounts(null);
        }
        catch (Exception ex)
        {
            ShowMessage("Cannot delete: " + ex.Message, false);
        }
    }

    protected void gvMainAccounts_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
    {
        // Focus changed - reload main accounts grid
        LoadMainAccounts();
    }

    protected void gvSubAccounts_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
    {
        string mainCode = e.Parameters;
        if (!string.IsNullOrEmpty(mainCode))
        {
            LoadSubAccounts(mainCode);
        }
        else
        {
            LoadSubAccounts(null);
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = "<div class='coa-msg " + (success ? "coa-msg--success" : "coa-msg--error") + "'>" + Server.HtmlEncode(msg) + "</div>";
        lblMessage.Visible = true;
    }
}
