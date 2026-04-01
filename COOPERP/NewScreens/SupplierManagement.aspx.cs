using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_SupplierManagement : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSuppliers();
        }
    }

    private void LoadSuppliers()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = "SELECT supplierID, supplierName, supplierAdress, supplierPhone FROM supplier ORDER BY supplierName";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }

            // Stats
            int total = dt.Rows.Count;
            int withAddr = 0, withPhone = 0;
            foreach (DataRow row in dt.Rows)
            {
                if (row["supplierAdress"] != DBNull.Value && !string.IsNullOrEmpty(row["supplierAdress"].ToString().Trim()))
                    withAddr++;
                if (row["supplierPhone"] != DBNull.Value && !string.IsNullOrEmpty(row["supplierPhone"].ToString().Trim()))
                    withPhone++;
            }
            litSupplierCount.Text = total.ToString("N0");
            litWithAddress.Text = withAddr.ToString("N0");
            litWithPhone.Text = withPhone.ToString("N0");
            litBadge.Text = string.Format("<span class='ft-card__meta'>{0} suppliers</span>", total);
            litFooter.Text = string.Format("<strong>{0}</strong> suppliers registered", total);
        }
        rptSuppliers.DataSource = dt;
        rptSuppliers.DataBind();
        phNoData.Visible = (dt.Rows.Count == 0);
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string name = txtSupplierName.Text.Trim();
        string address = txtSupplierAddress.Text.Trim();
        string phone = txtSupplierPhone.Text.Trim();
        string editId = hdnEditId.Value;

        if (string.IsNullOrEmpty(name))
        {
            ShowMessage("Please enter a supplier name.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                if (string.IsNullOrEmpty(editId))
                {
                    string sql = "INSERT INTO supplier (supplierName, supplierAdress, supplierPhone) VALUES (@n, @a, @p)";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@a", address);
                        cmd.Parameters.AddWithValue("@p", phone);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Supplier '" + name + "' added successfully.", true);
                }
                else
                {
                    string sql = "UPDATE supplier SET supplierName=@n, supplierAdress=@a, supplierPhone=@p WHERE supplierID=@id";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@a", address);
                        cmd.Parameters.AddWithValue("@p", phone);
                        cmd.Parameters.AddWithValue("@id", editId);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Supplier '" + name + "' updated successfully.", true);
                }
            }

            ClearForm();
            LoadSuppliers();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void rptSuppliers_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "EditSupplier")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length >= 4)
            {
                hdnEditId.Value = parts[0];
                txtSupplierName.Text = parts[1];
                txtSupplierAddress.Text = parts[2];
                txtSupplierPhone.Text = parts[3];
                btnSave.Text = "Update Supplier";
                btnCancel.Visible = true;
            }
        }
        else if (e.CommandName == "DeleteSupplier")
        {
            string id = e.CommandArgument.ToString();
            try
            {
                using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
                {
                    conn.Open();
                    string sql = "DELETE FROM supplier WHERE supplierID = @id";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMessage("Supplier deleted.", true);
                LoadSuppliers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    private void ClearForm()
    {
        hdnEditId.Value = "";
        txtSupplierName.Text = "";
        txtSupplierAddress.Text = "";
        txtSupplierPhone.Text = "";
        btnSave.Text = "+ Add Supplier";
        btnCancel.Visible = false;
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        string cssClass = isSuccess ? "ft-toast ft-toast--success" : "ft-toast ft-toast--error";
        litMsg.Text = "<div class='" + cssClass + "'>" + Server.HtmlEncode(msg) + "</div>";
    }
}
