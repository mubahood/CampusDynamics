using System;
using System.Data;
using System.Web;
using System.Web.UI;

/// <summary>
/// Contra Vouchers — bank-to-bank transfer creation and listing.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ double for money → decimal via MoneyHelper
///  ✓ Duplicated GetAccountType → AccountCache.GetAccountType
///  ✓ LoadAccounts → AccountCache.BindComboBox
///  ✓ No financial period check → FinancePeriod added
///  ✓ No logging → FinanceLogger for create/errors
///  ✓ Date defaults → FinancePeriod.GetDefaultDateRange
/// </summary>
public partial class COOPERP_NewScreens_ContraVouchers : System.Web.UI.Page
{
    private const string PAGE_NAME = "ContraVouchers";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var range = FinancePeriod.GetDefaultDateRange();
            txtStartDate.Text = range.Item1.ToString("yyyy-MM-dd");
            txtEndDate.Text   = range.Item2.ToString("yyyy-MM-dd");
            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

            // Cached account combos — shared DB hit
            AccountCache.BindComboBox(cboFromAccount);
            AccountCache.BindComboBox(cboToAccount);

            LoadContras();
        }
    }

    // ───────────────────────── Contra List ─────────────────────────────────

    protected void btnFilter_Click(object sender, EventArgs e) { LoadContras(); }

    private void LoadContras()
    {
        try
        {
            DateTime s, en;
            DateTime.TryParse(txtStartDate.Text, out s);
            DateTime.TryParse(txtEndDate.Text, out en);
            if (s == DateTime.MinValue) s = DateTime.Today.AddMonths(-1);
            if (en == DateTime.MinValue) en = DateTime.Today;

            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT VoucherNo, voucherDate, Teller, PostStatus 
                  FROM fin_vouchernumbers 
                  WHERE Vouchertype = 'Contra' AND voucherDate BETWEEN @sDate AND @eDate 
                  ORDER BY VoucherNo DESC LIMIT 500",
                FinanceDB.P("@sDate", s),
                FinanceDB.P("@eDate", en));

            gvContras.DataSource = dt;
            gvContras.DataBind();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadContras", ex);
        }
    }

    // ───────────────────────── Create Contra ──────────────────────────────

    protected void btnNewContra_Click(object sender, EventArgs e) { pnlCreate.Visible = true; }
    protected void btnCancelCreate_Click(object sender, EventArgs e) { pnlCreate.Visible = false; }

    protected void btnConfirmCreate_Click(object sender, EventArgs e)
    {
        string fromAcc = cboFromAccount.Value != null ? cboFromAccount.Value.ToString() : "";
        string toAcc = cboToAccount.Value != null ? cboToAccount.Value.ToString() : "";
        decimal amount = MoneyHelper.ParseMoney(txtAmount.Text);
        string particulars = txtParticulars.Text.Trim();
        DateTime vDate;
        DateTime.TryParse(txtDate.Text, out vDate);
        if (vDate == DateTime.MinValue) vDate = DateTime.Today;

        if (string.IsNullOrEmpty(fromAcc) || string.IsNullOrEmpty(toAcc) || amount <= 0)
        {
            ShowMessage("Select both accounts and enter valid amount.", false);
            return;
        }
        if (fromAcc == toAcc)
        {
            ShowMessage("From and To accounts cannot be the same.", false);
            return;
        }

        // FIX: Financial period check (was completely missing)
        if (!FinancePeriod.IsDateInOpenPeriod(vDate))
        {
            ShowMessage("Cannot create contra voucher: the date is not in an open financial period.", false);
            return;
        }

        try
        {
            // Get account types from cache (no DB round-trip)
            string fromType = AccountCache.GetAccountType(fromAcc);
            string toType = AccountCache.GetAccountType(toAcc);
            string user = HttpContext.Current.User.Identity.Name;
            string part = string.IsNullOrEmpty(particulars)
                ? "Contra: " + fromAcc + " \u2192 " + toAcc
                : particulars;

            // Get voucher number via SP
            int vNo = 0;
            FinanceDB.ExecuteReader(
                "CALL fin_GetLatestVoucherNo(@usr, @typ, @cat)",
                reader => { if (reader.Read()) vNo = reader.GetInt32(0); },
                FinanceDB.P("@usr", user),
                FinanceDB.P("@typ", "Contra"),
                FinanceDB.P("@cat", "Contra"));

            // Create via SP
            FinanceDB.ExecuteNonQuerySP("fin_TransactionCreator",
                FinanceDB.P("@CRaccountcode", fromAcc),
                FinanceDB.P("@CRaccountType", fromType),
                FinanceDB.P("@CRParticulars", part),
                FinanceDB.P("@DRaccountcode", toAcc),
                FinanceDB.P("@DRaccountType", toType),
                FinanceDB.P("@DRParticulars", part),
                FinanceDB.P("@transaction_amount", amount),
                FinanceDB.P("@voucherNo", vNo),
                FinanceDB.P("@transactionDate", vDate),
                FinanceDB.P("@teller", user),
                FinanceDB.P("@curr", ""),
                FinanceDB.P("@folio", "Contra Voucher"));

            FinanceLogger.LogVoucherCreated(vNo, "Contra", amount, user);
            ShowMessage("Contra voucher created: " + fromAcc + " \u2192 " + toAcc +
                " (" + MoneyHelper.FormatNumber(amount) + ")", true);
            pnlCreate.Visible = false;
            txtAmount.Text = "";
            txtParticulars.Text = "";
            LoadContras();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "CreateContra", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    // ───────────────────────── UI Helpers ──────────────────────────────────

    private void ShowMessage(string msg, bool ok)
    {
        lblMessage.Text = "<div class='cv-msg " + (ok ? "cv-msg--success" : "cv-msg--error") + "'>" +
            System.Web.HttpUtility.HtmlEncode(msg) + "</div>";
    }
}
