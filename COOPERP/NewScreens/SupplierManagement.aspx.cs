using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Supplier Management — CRUD for suppliers.
/// 
/// REFACTORED (Phase 2):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ In-memory stats loop → SQL COUNT with CASE
///  ✓ No error handling → try/catch + FinanceLogger.LogError
///  ✓ No audit trail → FinanceLogger.LogAction on add/update/delete
/// </summary>
public partial class COOPERP_NewScreens_SupplierManagement : System.Web.UI.Page
{
    private const string PAGE_NAME = "SupplierManagement";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSuppliers();
        }
    }

    private void LoadSuppliers()
    {
        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT supplierID, supplierName, supplierAdress, supplierPhone FROM supplier ORDER BY supplierName");

            // SQL-based stats instead of in-memory loop
            var stats = FinanceDB.ExecuteAggregateRow(
                @"SELECT COUNT(*) AS total,
                         SUM(CASE WHEN supplierAdress IS NOT NULL AND TRIM(supplierAdress) != '' THEN 1 ELSE 0 END) AS withAddr,
                         SUM(CASE WHEN supplierPhone IS NOT NULL AND TRIM(supplierPhone) != '' THEN 1 ELSE 0 END) AS withPhone
                  FROM supplier");

            int total = Convert.ToInt32(stats.ContainsKey("total") ? stats["total"] : 0);
            int withAddr = Convert.ToInt32(stats.ContainsKey("withAddr") ? stats["withAddr"] : 0);
            int withPhone = Convert.ToInt32(stats.ContainsKey("withPhone") ? stats["withPhone"] : 0);

            litSupplierCount.Text = total.ToString("N0");
            litWithAddress.Text = withAddr.ToString("N0");
            litWithPhone.Text = withPhone.ToString("N0");
            litBadge.Text = string.Format("<span class='ft-card__meta'>{0} suppliers</span>", total);
            litFooter.Text = string.Format("<strong>{0}</strong> suppliers registered", total);

            rptSuppliers.DataSource = dt;
            rptSuppliers.DataBind();
            phNoData.Visible = (dt.Rows.Count == 0);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadSuppliers", ex);
        }
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
            if (string.IsNullOrEmpty(editId))
            {
                FinanceDB.ExecuteNonQuery(
                    "INSERT INTO supplier (supplierName, supplierAdress, supplierPhone) VALUES (@n, @a, @p)",
                    FinanceDB.P("@n", name), FinanceDB.P("@a", address), FinanceDB.P("@p", phone));

                FinanceLogger.LogAction(PAGE_NAME, "AddSupplier", "Name=" + name);
                ShowMessage("Supplier '" + name + "' added successfully.", true);
            }
            else
            {
                FinanceDB.ExecuteNonQuery(
                    "UPDATE supplier SET supplierName=@n, supplierAdress=@a, supplierPhone=@p WHERE supplierID=@id",
                    FinanceDB.P("@n", name), FinanceDB.P("@a", address),
                    FinanceDB.P("@p", phone), FinanceDB.P("@id", editId));

                FinanceLogger.LogAction(PAGE_NAME, "UpdateSupplier", "ID=" + editId + " Name=" + name);
                ShowMessage("Supplier '" + name + "' updated successfully.", true);
            }

            ClearForm();
            LoadSuppliers();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnSave_Click", ex);
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
                FinanceDB.ExecuteNonQuery(
                    "DELETE FROM supplier WHERE supplierID = @id",
                    FinanceDB.P("@id", id));

                FinanceLogger.LogAction(PAGE_NAME, "DeleteSupplier", "ID=" + id);
                ShowMessage("Supplier deleted.", true);
                LoadSuppliers();
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "DeleteSupplier", ex);
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
        litMsg.Text = "<div class='" + cssClass + "'>" + HttpUtility.HtmlEncode(msg) + "</div>";
    }
}
