using System;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_LedgerCategories : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCategories();
        }
    }

    private void LoadCategories()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = "SELECT LedgerTypeID, LedgerTypeName, LedgerTypeCategory FROM fin_ledgertypes ORDER BY LedgerTypeCategory, LedgerTypeName";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        gridCategories.DataSource = dt;
        gridCategories.DataBind();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string name = txtCategoryName.Text.Trim();
        string category = ddlGeneralCategory.SelectedValue;
        string editId = hdnEditId.Value;

        if (string.IsNullOrEmpty(name))
        {
            ShowMessage("Please enter a category name.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("fin_LedgerCategoryEditor", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ltName", name);
                    cmd.Parameters.AddWithValue("@ltCategory", category);

                    if (!string.IsNullOrEmpty(editId))
                    {
                        // Update mode — SP may accept @ltID for updates
                        cmd.Parameters.AddWithValue("@ltID", int.Parse(editId));
                    }

                    cmd.ExecuteNonQuery();
                }
            }

            string action = string.IsNullOrEmpty(editId) ? "added" : "updated";
            ShowMessage("Category '" + name + "' " + action + " successfully.", true);
            txtCategoryName.Text = "";
            hdnEditId.Value = "";
            btnSave.Text = "+ Add Category";
            LoadCategories();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnEdit_Click(object sender, EventArgs e)
    {
        DevExpress.Web.ASPxButton btn = sender as DevExpress.Web.ASPxButton;
        if (btn == null) return;

        string[] parts = btn.CommandArgument.Split('|');
        if (parts.Length >= 3)
        {
            hdnEditId.Value = parts[0];
            txtCategoryName.Text = parts[1];
            try { ddlGeneralCategory.SelectedValue = parts[2]; } catch { }
            btnSave.Text = "Update Category";
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        DevExpress.Web.ASPxButton btn = sender as DevExpress.Web.ASPxButton;
        if (btn == null) return;
        string id = btn.CommandArgument;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("fin_DeleteLedgerCategory", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ltID", int.Parse(id));
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Category deleted successfully.", true);
            LoadCategories();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "lc-msg lc-msg-ok" : "lc-msg lc-msg-err";
        litMsg.Text = msg;
    }
}
