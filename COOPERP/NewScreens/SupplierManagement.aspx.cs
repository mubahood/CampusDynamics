using System;
using System.Data;
using System.Web.UI;
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
        }
        gridSuppliers.DataSource = dt;
        gridSuppliers.DataBind();
        litSupplierCount.Text = dt.Rows.Count.ToString();
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
                    // Insert new
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
                    // Update existing
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

    protected void btnEdit_Click(object sender, EventArgs e)
    {
        DevExpress.Web.ASPxButton btn = sender as DevExpress.Web.ASPxButton;
        if (btn == null) return;

        string[] parts = btn.CommandArgument.Split('|');
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
        pnlMsg.CssClass = isSuccess ? "sm-msg sm-msg-ok" : "sm-msg sm-msg-err";
        litMsg.Text = msg;
    }
}
