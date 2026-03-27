using System;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;
using DevExpress.Web;

public partial class COOPERP_NewScreens_FinancialPeriods : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadPeriods();
        }
    }

    private void LoadPeriods()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = "SELECT id, finacial_Year, start_date, end_date, status FROM fin_financial_years ORDER BY start_date DESC";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        gridPeriods.DataSource = dt;
        gridPeriods.DataBind();
    }

    protected void btnAddPeriod_Click(object sender, EventArgs e)
    {
        string finYear = txtFinYear.Text.Trim();
        string startStr = txtPeriodStart.Text.Trim();
        string endStr = txtPeriodEnd.Text.Trim();
        string status = ddlStatus.SelectedValue;

        if (string.IsNullOrEmpty(finYear) || string.IsNullOrEmpty(startStr) || string.IsNullOrEmpty(endStr))
        {
            ShowMessage("Please fill in all fields.", false);
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(startStr, out startDate) || !DateTime.TryParse(endStr, out endDate))
        {
            ShowMessage("Invalid date format.", false);
            return;
        }

        if (endDate <= startDate)
        {
            ShowMessage("End date must be after start date.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                string sql = "INSERT INTO fin_financial_years (finacial_Year, start_date, end_date, status) VALUES (@fy, @sd, @ed, @st)";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@fy", finYear);
                    cmd.Parameters.AddWithValue("@sd", startDate.ToString("yyyy-MM-dd"));
                    cmd.Parameters.AddWithValue("@ed", endDate.ToString("yyyy-MM-dd"));
                    cmd.Parameters.AddWithValue("@st", status);
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Financial period '" + finYear + "' added successfully.", true);
            txtFinYear.Text = "";
            txtPeriodStart.Text = "";
            txtPeriodEnd.Text = "";
            LoadPeriods();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnToggle_Click(object sender, EventArgs e)
    {
        DevExpress.Web.ASPxButton btn = sender as DevExpress.Web.ASPxButton;
        if (btn == null) return;
        string id = btn.CommandArgument;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Get current status
                string currentStatus = "";
                using (MySqlCommand cmd = new MySqlCommand("SELECT status FROM fin_financial_years WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    object result = cmd.ExecuteScalar();
                    currentStatus = result != null ? result.ToString() : "";
                }

                string newStatus = currentStatus == "Open" ? "Closed" : "Open";

                // If opening a period, close all others first
                if (newStatus == "Open")
                {
                    using (MySqlCommand cmd = new MySqlCommand("UPDATE fin_financial_years SET status = 'Closed' WHERE status = 'Open'", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }

                using (MySqlCommand cmd = new MySqlCommand("UPDATE fin_financial_years SET status = @st WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@st", newStatus);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Period status changed to '" + newStatus + "'.", true);
            }
            LoadPeriods();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
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

                // Check if period is open - prevent deletion of open period
                using (MySqlCommand cmd = new MySqlCommand("SELECT status FROM fin_financial_years WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result.ToString() == "Open")
                    {
                        ShowMessage("Cannot delete an open financial period. Close it first.", false);
                        return;
                    }
                }

                using (MySqlCommand cmd = new MySqlCommand("DELETE FROM fin_financial_years WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Financial period deleted.", true);
            }
            LoadPeriods();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void gridPeriods_CustomButtonCallback(object sender, ASPxGridViewCustomButtonCallbackEventArgs e)
    {
        // Not used - using template buttons instead
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "fp-msg fp-msg-ok" : "fp-msg fp-msg-err";
        litMsg.Text = msg;
    }
}
