using System;
using System.Data;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_JournalEntries : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            LoadAccountsCombo();
            LoadJournals();
        }
    }

    private void LoadAccountsCombo()
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT AccountCode, AccountName FROM fin_subaccounts ORDER BY AccountCode", conn))
            {
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        cboDetailAccount.DataSource = dt;
        cboDetailAccount.DataBind();
    }

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadJournals();
    }

    private void LoadJournals()
    {
        DateTime startDate, endDate;
        DateTime.TryParse(txtStartDate.Text, out startDate);
        DateTime.TryParse(txtEndDate.Text, out endDate);
        if (startDate == DateTime.MinValue) startDate = DateTime.Today.AddMonths(-1);
        if (endDate == DateTime.MinValue) endDate = DateTime.Today;

        string journalType = ddlJournalType.SelectedValue;
        string status = ddlStatus.SelectedValue;

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT JournalNo, journalType, journalDate, RefNo, journalParticulars, 
                                  GL_VoucherNo, Teller, PostStatus 
                           FROM fin_journalnumbers 
                           WHERE journalDate BETWEEN @sDate AND @eDate";
            if (!string.IsNullOrEmpty(journalType))
                sql += " AND journalType = @typ";
            if (!string.IsNullOrEmpty(status))
                sql += " AND PostStatus = @status";
            sql += " ORDER BY JournalNo DESC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sDate", startDate);
                cmd.Parameters.AddWithValue("@eDate", endDate);
                if (!string.IsNullOrEmpty(journalType))
                    cmd.Parameters.AddWithValue("@typ", journalType);
                if (!string.IsNullOrEmpty(status))
                    cmd.Parameters.AddWithValue("@status", status);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        gvJournals.DataSource = dt;
        gvJournals.DataBind();
    }

    protected void btnCreateJournal_Click(object sender, EventArgs e)
    {
        pnlCreateJournal.Visible = true;
    }

    protected void btnCancelCreate_Click(object sender, EventArgs e)
    {
        pnlCreateJournal.Visible = false;
    }

    protected void btnConfirmCreate_Click(object sender, EventArgs e)
    {
        string journalType = ddlNewJournalType.SelectedValue;
        string refNo = txtNewRefNo.Text.Trim();
        string particulars = txtNewParticulars.Text.Trim();
        string user = HttpContext.Current.User.Identity.Name;

        // Check open financial period
        if (!IsInOpenFinancialPeriod())
        {
            ShowMessage("Cannot create journal: No open financial period.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                // Create journal header
                using (MySqlCommand cmd = new MySqlCommand("fin_CreateJournal", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@typ", journalType);
                    cmd.Parameters.AddWithValue("@JDate", DateTime.Today);
                    cmd.Parameters.AddWithValue("@usr", user);
                    cmd.ExecuteNonQuery();
                }

                // Get the newly created journal number
                int newJournalNo = 0;
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT JournalNo FROM fin_journalnumbers WHERE teller = @usr AND journalType = @typ ORDER BY JournalNo DESC LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@usr", user);
                    cmd.Parameters.AddWithValue("@typ", journalType);
                    newJournalNo = Convert.ToInt32(cmd.ExecuteScalar());
                }

                // Update RefNo and Particulars
                if (!string.IsNullOrEmpty(refNo))
                {
                    using (MySqlCommand cmd = new MySqlCommand(
                        "UPDATE fin_journalnumbers SET RefNo = @ref WHERE JournalNo = @jno", conn))
                    {
                        cmd.Parameters.AddWithValue("@ref", refNo);
                        cmd.Parameters.AddWithValue("@jno", newJournalNo);
                        cmd.ExecuteNonQuery();
                    }
                }
                if (!string.IsNullOrEmpty(particulars))
                {
                    using (MySqlCommand cmd = new MySqlCommand(
                        "UPDATE fin_journalnumbers SET journalParticulars = @part WHERE JournalNo = @jno", conn))
                    {
                        cmd.Parameters.AddWithValue("@part", particulars);
                        cmd.Parameters.AddWithValue("@jno", newJournalNo);
                        cmd.ExecuteNonQuery();
                    }
                }

                Session["ActiveJournalNo"] = newJournalNo;
                ShowMessage("Journal #" + newJournalNo + " created. Add detail lines below.", true);
                pnlCreateJournal.Visible = false;
                LoadJournals();
                LoadJournalDetail(newJournalNo);
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error creating journal: " + ex.Message, false);
        }
    }

    protected void gvJournals_FocusedRowChanged(object sender, EventArgs e)
    {
        if (gvJournals.FocusedRowIndex >= 0)
        {
            object key = gvJournals.GetRowValues(gvJournals.FocusedRowIndex, "JournalNo");
            if (key != null)
            {
                int jno = Convert.ToInt32(key);
                Session["ActiveJournalNo"] = jno;
                LoadJournalDetail(jno);
            }
        }
    }

    private void LoadJournalDetail(int journalNo)
    {
        pnlJournalDetail.Visible = true;

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Load journal header info
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT JournalNo, journalType, journalDate, RefNo, PostStatus, journalParticulars 
                  FROM fin_journalnumbers WHERE JournalNo = @jno", conn))
            {
                cmd.Parameters.AddWithValue("@jno", journalNo);
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblJournalNo.Text = reader["JournalNo"].ToString();
                        lblJournalType.Text = reader["journalType"].ToString();
                        lblJournalDate.Text = reader.GetDateTime("journalDate").ToString("dd MMM yyyy");
                        lblRefNo.Text = reader["RefNo"] != DBNull.Value ? reader["RefNo"].ToString() : "-";
                        lblPostStatus.Text = reader["PostStatus"].ToString();

                        // If already approved, hide add line and approve button
                        bool isNew = reader["PostStatus"].ToString() == "New";
                        pnlAddLine.Visible = isNew;
                        btnApproveJournal.Visible = isNew;
                    }
                }
            }

            // Load detail lines
            DataTable dt = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT TID, accountcode, account_type, transactionType, transaction_amount, particulars 
                  FROM fin_journal_details WHERE journal_no = @jno ORDER BY TID", conn))
            {
                cmd.Parameters.AddWithValue("@jno", journalNo);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
            gvDetails.DataSource = dt;
            gvDetails.DataBind();

            // Calculate balance
            double totalDR = 0, totalCR = 0;
            foreach (DataRow row in dt.Rows)
            {
                double amt = Convert.ToDouble(row["transaction_amount"]);
                if (row["transactionType"].ToString() == "DR") totalDR += amt;
                else totalCR += amt;
            }
            bool balanced = Math.Abs(totalDR - totalCR) < 0.01;
            if (balanced && dt.Rows.Count > 0)
                lblBalanceIndicator.Text = "<span class='je-balance-indicator je-balance--ok'>BALANCED (DR=" + totalDR.ToString("N0") + " CR=" + totalCR.ToString("N0") + ")</span>";
            else if (dt.Rows.Count > 0)
                lblBalanceIndicator.Text = "<span class='je-balance-indicator je-balance--off'>UNBALANCED (DR=" + totalDR.ToString("N0") + " CR=" + totalCR.ToString("N0") + ")</span>";
            else
                lblBalanceIndicator.Text = "<span style='font-size:11px;color:#888;'>No lines added yet</span>";
        }
    }

    protected void btnAddLine_Click(object sender, EventArgs e)
    {
        if (Session["ActiveJournalNo"] == null)
        {
            ShowMessage("No active journal selected.", false);
            return;
        }

        int jno = Convert.ToInt32(Session["ActiveJournalNo"]);
        string accCode = cboDetailAccount.Value != null ? cboDetailAccount.Value.ToString() : "";
        string transType = ddlDetailType.SelectedValue;
        string details = txtDetailParticulars.Text.Trim();
        double amount = 0;
        double.TryParse(txtDetailAmount.Text, out amount);

        if (string.IsNullOrEmpty(accCode) || amount <= 0)
        {
            ShowMessage("Select an account and enter a valid amount.", false);
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Get account type
                string accType = "";
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT accounttype FROM fin_subaccounts WHERE AccountCode = @acc", conn))
                {
                    cmd.Parameters.AddWithValue("@acc", accCode);
                    object result = cmd.ExecuteScalar();
                    accType = result != null ? result.ToString() : "";
                }

                using (MySqlCommand cmd = new MySqlCommand("fin_AddJournalDetails", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@jno", jno);
                    cmd.Parameters.AddWithValue("@usr", HttpContext.Current.User.Identity.Name);
                    cmd.Parameters.AddWithValue("@accCode", accCode);
                    cmd.Parameters.AddWithValue("@AccType", accType);
                    cmd.Parameters.AddWithValue("@details", string.IsNullOrEmpty(details) ? accCode + " entry" : details);
                    cmd.Parameters.AddWithValue("@typ", transType);
                    cmd.Parameters.AddWithValue("@refNo", amount);
                    cmd.ExecuteNonQuery();
                }
            }
            txtDetailAmount.Text = "";
            txtDetailParticulars.Text = "";
            LoadJournalDetail(jno);
        }
        catch (Exception ex)
        {
            ShowMessage("Error adding line: " + ex.Message, false);
        }
    }

    protected void gvDetails_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        e.Cancel = true;
        int tid = Convert.ToInt32(e.Keys["TID"]);
        int jno = Session["ActiveJournalNo"] != null ? Convert.ToInt32(Session["ActiveJournalNo"]) : 0;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("fin_Delete_journal_item", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@_id", tid);
                    cmd.Parameters.AddWithValue("@jno", jno);
                    cmd.ExecuteNonQuery();
                }
            }
            LoadJournalDetail(jno);
        }
        catch (Exception ex)
        {
            ShowMessage("Error removing line: " + ex.Message, false);
        }
    }

    protected void btnApproveJournal_Click(object sender, EventArgs e)
    {
        if (Session["ActiveJournalNo"] == null) return;
        int jno = Convert.ToInt32(Session["ActiveJournalNo"]);

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Get journal type
                string journalType = "";
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT journalType FROM fin_journalnumbers WHERE JournalNo = @jno", conn))
                {
                    cmd.Parameters.AddWithValue("@jno", jno);
                    object jtResult = cmd.ExecuteScalar();
                    journalType = jtResult != null ? jtResult.ToString() : "General";
                }

                using (MySqlCommand cmd = new MySqlCommand("fin_ApproveJournal_Safe", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@jno", jno);
                    cmd.Parameters.AddWithValue("@usr", HttpContext.Current.User.Identity.Name);
                    cmd.Parameters.AddWithValue("@typ", journalType);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowMessage("Journal #" + jno + " approved and posted to ledger.", true);
            LoadJournalDetail(jno);
            LoadJournals();
        }
        catch (Exception ex)
        {
            ShowMessage("Error approving: " + ex.Message, false);
        }
    }

    protected void btnCloseDetail_Click(object sender, EventArgs e)
    {
        pnlJournalDetail.Visible = false;
        Session["ActiveJournalNo"] = null;
    }

    private bool IsInOpenFinancialPeriod()
    {
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM fin_financial_years WHERE status = 'Open' AND @today BETWEEN start_date AND end_date", conn))
            {
                cmd.Parameters.AddWithValue("@today", DateTime.Today);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = "<div class='je-msg " + (success ? "je-msg--success" : "je-msg--error") + "'>" + Server.HtmlEncode(msg) + "</div>";
    }
}
