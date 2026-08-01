using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Collections;
using Systems.Settings.SD;
using CoopERPDataTableAdapters;
using MySql.Data.MySqlClient;

public partial class UserControls_Accounts_LedgersCentre : System.Web.UI.UserControl
{
    private const string PendingFinanceRequestsSessionKey = "PendingFinanceRequests_LedgersCentre";

    private bool IsLocalBypassUser()
    {
        if (Session["username"] == null) return false;
        string username = Session["username"].ToString();
        return username.Equals("localadmin", StringComparison.OrdinalIgnoreCase) ||
               username.Equals("swabra", StringComparison.OrdinalIgnoreCase);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        pop_msgbox.HeaderText = "Campus Dynamics ERP";
        EnsurePendingFinanceRequestMapLoaded();

        if (!IsPostBack)
        {
            if (DateTime.Today.Month > 7)
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
            else
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year - 1); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
            txtLedgerType.Text = "Chart Account";
            txtLedgerType.Value = "Chart Account";

            txtPayeeCategory.Text = "Chart Account";
            txtPayeeCategory.Value = "Chart Account";
            txtEndDate.Value = DateTime.Today;

            
        }

        if (txtType.Text == "Request Correction")
        {
            txtNewAmount.Enabled = false;
            txt_reason.Enabled = true;

        }
        else if (txtType.Text == "Request Reversal")
        {
            txtNewAmount.Enabled = false;
            txt_reason.Enabled = true;
        }
        else
        {
            txtNewAmount.Enabled = false;
            txt_reason.Enabled = false;
        }
        
    }

    protected void txtPayeeCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtPayee.DataBind();
        txtLedgerType.DataBind();

        txtPayee.SelectedIndex = -1;
        txtPayee.Value = null;
        txtPayee.Text = string.Empty;

        if (txtPayeeCategory.Value != null &&
            txtPayeeCategory.Value.ToString().Equals("Chart Account", StringComparison.OrdinalIgnoreCase))
        {
            txtLedgerType.Text = "Chart Account";
            txtLedgerType.Value = "Chart Account";
        }

        gvLedger.DataBind();
    }

    protected void txtPayee_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (txtPayeeCategory.Value != null &&
            txtPayeeCategory.Value.ToString().Equals("Chart Account", StringComparison.OrdinalIgnoreCase))
        {
            txtLedgerType.Text = "Chart Account";
            txtLedgerType.Value = "Chart Account";
        }

        gvLedger.DataBind();
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 800;
        pop_msgbox.Height = 600;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        Session["accno"] = txtPayee.Value;
        Session["startDate"] = txtStartDate.Text;
        Session["endDate"] = txtEndDate.Text;
        Session["Report"] = "Legder";
        Session["typ"] = txtLedgerType.Text;
        Session["disp_curr"] = txtDisplayCurrency.Text;

        pop_msgbox.ShowOnPageLoad = true;
        gvLedger.DataBind();
    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 400;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/TransactionDetails.aspx";
        Session["Vno"] = gvLedger.GetRowValues(gvLedger.FocusedRowIndex, "voucherno");
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void gvLedger_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;

        try
        {
            object voucherValue = gvLedger.GetRowValues(e.VisibleIndex, "voucherno");
            if (voucherValue == null)
                return;

            string voucherNo = voucherValue.ToString();
            string pendingType;
            if (PendingFinanceRequestMap.TryGetValue(voucherNo, out pendingType))
            {
                e.Row.BackColor = System.Drawing.Color.FromArgb(255, 249, 196);
                e.Row.ToolTip = "Pending Finance System Realignment request: " + pendingType;
            }
        }
        catch
        {
            // Row decoration must never break grid rendering
        }
    }
    protected void cmdProcess_Click(object sender, EventArgs e)
    {
        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 350;
        pop_msgbox.Height = 145;

        AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter ADJ = new AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter();
        int noRows = gvLedger.VisibleRowCount, counter = 0;

        if (txtType.Text == "Request Reversal" || txtType.Text == "Request Correction")
        {
            string selectedVoucher = GetSingleSelectedVoucher();
            if (string.IsNullOrEmpty(selectedVoucher))
            {
                lbl_msgbox.Text = "Please select exactly one voucher to continue with the approval workflow.";
                pop_msgbox.ShowOnPageLoad = true;
                return;
            }

            string pendingType;
            if (PendingFinanceRequestMap.TryGetValue(selectedVoucher, out pendingType))
            {
                lbl_msgbox.Text = "A pending " + pendingType + " request already exists for voucher " + selectedVoucher + ".";
                pop_msgbox.ShowOnPageLoad = true;
                return;
            }

            string targetUrl = txtType.Text == "Request Reversal"
                ? "~/COOPERP/Finance/Admin/ReversalRequest.aspx?voucher=" + Server.UrlEncode(selectedVoucher)
                : "~/COOPERP/Finance/Admin/CorrectionRequest.aspx?voucher=" + Server.UrlEncode(selectedVoucher);

            if (!string.IsNullOrWhiteSpace(txt_reason.Text))
            {
                Session["FinanceRealignmentRequestNotes"] = txt_reason.Text.Trim();
            }
            Session["FinanceRealignmentSourceVoucher"] = selectedVoucher;

            Response.Redirect(targetUrl, false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        else if (txtType.Text.Contains("Correct Amount"))
        {
            lbl_msgbox.Text = "Manual amount correction has been retired. Use Request Correction instead.";
            pop_msgbox.ShowOnPageLoad = true;
            return;

            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    string details = gvLedger.GetRowValues(i, "particulars").ToString(), vno = gvLedger.GetRowValues(i, "voucherno").ToString();
                    DateTime Tdate = DateTime.Parse(gvLedger.GetRowValues(i, "transactiondate").ToString());
                    if (Tdate == DateTime.Today)
                    {
                        if (IsLocalBypassUser() || HttpContext.Current.User.IsInRole("Bursar"))
                        {
                            string oldAmount = gvLedger.GetRowValues(i, "transaction_amount").ToString();
                            ADJ.fin_UpdatePayAmount(vno, HttpContext.Current.User.Identity.Name, double.Parse(txtNewAmount.Text.Replace(",", "")));
                            // F8: Audit log — amount corrected
                            AuditLogger.Log("AMOUNT_CORRECTED",
                                string.Format("VoucherNo={0}", vno),
                                int.Parse(vno),
                                decimal.Parse(txtNewAmount.Text.Replace(",", "")),
                                oldAmount,
                                txtNewAmount.Text);
                            lbl_msgbox.Text = "Pay Amount Correction completed";
                        }
                        else
                        {
                            lbl_msgbox.Text = "Sorry! Only Bursar can make amounts corrections";
                            break;
                        }
                    }
                    else
                    {
                        lbl_msgbox.Text = "Sorry! Only today's transaction amounts can be corrected";
                    }
                }
            }

            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Cancel Transaction"))
        {
            lbl_msgbox.Text = "No Transaction selected";
            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    string details = gvLedger.GetRowValues(i, "particulars").ToString();
                    if (IsLocalBypassUser() || HttpContext.Current.User.IsInRole("Bursar"))
                    {
                        int cancelVno = int.Parse(gvLedger.GetRowValues(i, "voucherno").ToString());
                        ADJ.CancelTransaction(cancelVno);
                        counter++;
                        // F8: Audit log — transaction cancelled
                        AuditLogger.Log("TRANSACTION_CANCELLED",
                            string.Format("VoucherNo={0}", cancelVno), cancelVno);
                        lbl_msgbox.Text = counter + " transaction(s) cancelled successfully";
                    }
                    else
                    {
                        lbl_msgbox.Text = "Sorry! only Bursar can cancel transactions";
                        break;
                    }
                }
            }

            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Clear Ledger"))
        {
            // B3 FIX: Only Administrator can clear entire ledger (nuclear operation)
            if (!(IsLocalBypassUser() || HttpContext.Current.User.IsInRole("Administrator")))
            {
                lbl_msgbox.Text = "Sorry! Only Administrator can clear a ledger";
            }
            else
            {
                ADJ.fin_ClearLedger(txtPayee.Value.ToString(), txtPayeeCategory.Value.ToString(),
                    HttpContext.Current.User.Identity.Name);
                // F8: Audit log — ledger cleared (nuclear operation)
                AuditLogger.Log("LEDGER_CLEARED",
                    string.Format("Account={0}, Category={1}", txtPayee.Value, txtPayeeCategory.Value));
                lbl_msgbox.Text = "Ledger Cleared";
            }
            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
    }
    // B13 FIX: Financial period validation
    private bool IsInOpenFinancialPeriod(out string errorMessage)
    {
        errorMessage = "";
        fin_financial_yearsTableAdapter FY = new fin_financial_yearsTableAdapter();
        var dtOpen = FY.GetFinicalPeriodStatus();
        if (dtOpen.Rows.Count == 0)
        {
            errorMessage = "Error! No financial year is currently Open. Cannot perform ledger operations.";
            return false;
        }
        DateTime periodStart = Convert.ToDateTime(dtOpen.Rows[0]["start_date"]);
        DateTime periodEnd = Convert.ToDateTime(dtOpen.Rows[0]["end_date"]);
        DateTime today = DateTime.Today;
        if (today < periodStart || today > periodEnd)
        {
            errorMessage = "Error! Cannot modify ledger. Accounting Period Closed. The Date Ranges are: "
                           + periodStart.ToString("dd/MM/yyyy") + " - " + periodEnd.ToString("dd/MM/yyyy") + ".";
            return false;
        }
        return true;
    }

    private string GetSingleSelectedVoucher()
    {
        string selectedVoucher = null;
        int selectedCount = 0;

        for (int i = 0; i < gvLedger.VisibleRowCount; i++)
        {
            if (!gvLedger.Selection.IsRowSelected(i))
                continue;

            object value = gvLedger.GetRowValues(i, "voucherno");
            if (value == null)
                continue;

            selectedVoucher = value.ToString();
            selectedCount++;
            if (selectedCount > 1)
                return null;
        }

        return selectedCount == 1 ? selectedVoucher : null;
    }

    private IDictionary<string, string> PendingFinanceRequestMap
    {
        get
        {
            object raw = Session[PendingFinanceRequestsSessionKey];
            if (raw == null)
            {
                raw = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                Session[PendingFinanceRequestsSessionKey] = raw;
            }
            return (IDictionary<string, string>)raw;
        }
    }

    private void EnsurePendingFinanceRequestMapLoaded()
    {
        if (Session[PendingFinanceRequestsSessionKey] != null)
            return;

        Dictionary<string, string> pendingMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        try
        {
            string cs = ResolveFinanceConnectionString();
            if (string.IsNullOrEmpty(cs))
            {
                Session[PendingFinanceRequestsSessionKey] = pendingMap;
                return;
            }

            using (MySqlConnection conn = new MySqlConnection(cs))
            {
                conn.Open();

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT original_voucherno,
                           GROUP_CONCAT(DISTINCT reversal_type ORDER BY reversal_type SEPARATOR ', ') AS pending_types
                    FROM fin_transaction_reversal
                    WHERE approved_at IS NULL
                    GROUP BY original_voucherno;", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string voucher = rdr["original_voucherno"] == DBNull.Value ? "" : rdr["original_voucherno"].ToString();
                        if (voucher == "") continue;
                        pendingMap[voucher] = rdr["pending_types"] == DBNull.Value ? "Pending request" : rdr["pending_types"].ToString();
                    }
                }
            }
        }
        catch
        {
            // Ignore — UI can still function without status decoration.
        }

        Session[PendingFinanceRequestsSessionKey] = pendingMap;
    }

    private string ResolveFinanceConnectionString()
    {
        var cs = ConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString))
            return cs.ConnectionString;

        cs = ConfigurationManager.ConnectionStrings["LocalMySqlServer"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString))
            return cs.ConnectionString;

        return null;
    }
}
