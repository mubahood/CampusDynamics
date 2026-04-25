using System;
using System.Text;

public partial class COOPERP_NewScreens_FeeAccessPolicy : System.Web.UI.Page
{
    private readonly FeeAccessPolicyRepository _repo = new FeeAccessPolicyRepository();
    private readonly FeeAccessPolicyPreviewService _preview = new FeeAccessPolicyPreviewService();

    // ─── Lifecycle ───────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        _repo.EnsureSchema();
        if (!IsPostBack)
        {
            BindForm(_repo.LoadSingleton(CurrentUser()));
        }
    }

    // ─── SAVE ALL ────────────────────────────────────────────────────────
    protected void btnSave_Click(object sender, EventArgs e)
    {
        // --- Validate general ---
        string title = txtTitle.Text.Trim();
        if (string.IsNullOrEmpty(title))
        {
            ShowBanner("Policy title is required.", false);
            return;
        }

        // Policy status from plain HTML radio buttons (name="fap_is_active")
        string postedVal = Request.Form["fap_is_active"];
        bool isActive = string.Equals(postedVal, "yes", StringComparison.OrdinalIgnoreCase);

        // --- Validate rule fields ---
        decimal balMax, winAmt, pctMin, burMin;
        if (!TryDec(txtBalMax.Text, out balMax)) { ShowBanner("Invalid balance amount.", false); return; }
        if (!TryDec(txtWinAmt.Text, out winAmt)) { ShowBanner("Invalid payment window amount.", false); return; }
        if (!TryDec(txtPctMin.Text, out pctMin)) { ShowBanner("Invalid percentage value.", false); return; }
        if (!TryDec(txtBurMin.Text, out burMin)) { ShowBanner("Invalid bursary coverage value.", false); return; }

        bool winEnabled = ddlWinOn.SelectedValue == "yes";
        DateTime? winStart = ParseDateOrNull(txtWinStart.Text);
        DateTime? winEnd   = ParseDateOrNull(txtWinEnd.Text);
        if (winEnabled && (!winStart.HasValue || !winEnd.HasValue))
        {
            ShowBanner("Payment window dates are required when that rule is enabled.", false);
            return;
        }

        // --- Build config ---
        FeeAccessPolicyConfig cfg = new FeeAccessPolicyConfig
        {
            PolicyTitle = title,
            IsActive = isActive,
            RuleLogic = ddlLogic.SelectedValue,
            PolicyNotes = txtNotes.Text.Trim(),
            AcademicYear = FeeAccessPolicyRuntime.CurrentAcadYear(),
            Semester = FeeAccessPolicyRuntime.CurrentSemester(),
            RuleMinBalanceEnabled = ddlBalOn.SelectedValue == "yes",
            RuleMinBalanceAmount = balMax,
            RulePaymentWindowEnabled = winEnabled,
            RulePaymentMinAmount = winAmt,
            RulePaymentWindowStart = winStart,
            RulePaymentWindowEnd = winEnd,
            RulePctPaidEnabled = ddlPctOn.SelectedValue == "yes",
            RulePctPaidMinimum = pctMin,
            RuleBursaryExempt = ddlBurOn.SelectedValue == "yes",
            RuleBursaryMinCoverage = burMin,
            RuleRequireRegistration = ddlRegOn.SelectedValue == "yes"
        };

        // --- Save general, then rules ---
        string user = CurrentUser();
        FeeAccessPolicyConfig saved = _repo.SaveGeneral(cfg, user);
        // Copy the rule fields onto the saved object (it came back from SaveGeneral
        // which only persists general columns).
        saved.RuleMinBalanceEnabled = cfg.RuleMinBalanceEnabled;
        saved.RuleMinBalanceAmount = cfg.RuleMinBalanceAmount;
        saved.RulePaymentWindowEnabled = cfg.RulePaymentWindowEnabled;
        saved.RulePaymentMinAmount = cfg.RulePaymentMinAmount;
        saved.RulePaymentWindowStart = cfg.RulePaymentWindowStart;
        saved.RulePaymentWindowEnd = cfg.RulePaymentWindowEnd;
        saved.RulePctPaidEnabled = cfg.RulePctPaidEnabled;
        saved.RulePctPaidMinimum = cfg.RulePctPaidMinimum;
        saved.RuleBursaryExempt = cfg.RuleBursaryExempt;
        saved.RuleBursaryMinCoverage = cfg.RuleBursaryMinCoverage;
        saved.RuleRequireRegistration = cfg.RuleRequireRegistration;

        saved = _repo.SaveRules(saved, user);

        BindForm(saved);
        ShowBanner(string.Format("All settings saved. Policy is {0}.",
            saved.IsActive ? "ENABLED" : "DISABLED"), true);
    }

    // ─── PREVIEW IMPACT ──────────────────────────────────────────────────
    protected void btnPreview_Click(object sender, EventArgs e)
    {
        FeeAccessPolicyConfig policy = _repo.LoadSingleton(CurrentUser());
        BindForm(policy);

        FeeAccessPreviewResult result = _preview.Run(policy);
        if (!result.Success)
        {
            ShowPreview("<div class='fap-notice' style='margin-top:12px;'>" + Server.HtmlEncode(result.Message) + "</div>");
            return;
        }

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='fap-preview-stats'>");
        sb.AppendFormat("<div class='fap-stat fap-stat--total'><div class='fap-stat__val'>{0:N0}</div><div class='fap-stat__label'>Total Students</div></div>", result.TotalStudents);
        sb.AppendFormat("<div class='fap-stat fap-stat--pass'><div class='fap-stat__val'>{0:N0}</div><div class='fap-stat__label'>Would Be Allowed</div></div>", result.AllowedStudents);
        sb.AppendFormat("<div class='fap-stat fap-stat--fail'><div class='fap-stat__val'>{0:N0}</div><div class='fap-stat__label'>Would Be Denied</div></div>", result.DeniedStudents);
        sb.Append("</div>");

        if (result.TotalStudents > 0)
        {
            decimal allowedPct = Math.Round((decimal)result.AllowedStudents / result.TotalStudents * 100, 1);
            decimal deniedPct  = Math.Round((decimal)result.DeniedStudents  / result.TotalStudents * 100, 1);
            sb.AppendFormat("<p style='font-size:12px;color:#555;margin-top:8px;'>{0}% of students would be allowed access, {1}% would be denied.</p>",
                allowedPct, deniedPct);
        }

        ShowPreview(sb.ToString());
    }

    // ─── Bind form from config ───────────────────────────────────────────
    private void BindForm(FeeAccessPolicyConfig p)
    {
        if (p == null) p = new FeeAccessPolicyConfig();

        // General
        SetDDL(ddlLogic, string.IsNullOrEmpty(p.RuleLogic) ? "ALL" : p.RuleLogic);
        txtTitle.Text = p.PolicyTitle;
        txtNotes.Text = p.PolicyNotes;

        // Rules
        SetDDL(ddlBalOn, p.RuleMinBalanceEnabled ? "yes" : "no");
        txtBalMax.Text = p.RuleMinBalanceAmount.ToString("G");
        SetDDL(ddlWinOn, p.RulePaymentWindowEnabled ? "yes" : "no");
        txtWinAmt.Text = p.RulePaymentMinAmount.ToString("G");
        txtWinStart.Text = p.RulePaymentWindowStart.HasValue ? p.RulePaymentWindowStart.Value.ToString("yyyy-MM-dd") : "";
        txtWinEnd.Text = p.RulePaymentWindowEnd.HasValue ? p.RulePaymentWindowEnd.Value.ToString("yyyy-MM-dd") : "";
        SetDDL(ddlPctOn, p.RulePctPaidEnabled ? "yes" : "no");
        txtPctMin.Text = p.RulePctPaidMinimum.ToString("G");
        SetDDL(ddlBurOn, p.RuleBursaryExempt ? "yes" : "no");
        txtBurMin.Text = p.RuleBursaryMinCoverage.ToString("G");
        SetDDL(ddlRegOn, p.RuleRequireRegistration ? "yes" : "no");

        // Last updated
        pnlLastUpdated.Visible = p.UpdatedAt.HasValue || p.CreatedAt.HasValue;
        if (pnlLastUpdated.Visible)
        {
            DateTime stamp = p.UpdatedAt.HasValue ? p.UpdatedAt.Value : p.CreatedAt.Value;
            string who = !string.IsNullOrEmpty(p.UpdatedBy) ? p.UpdatedBy : p.CreatedBy;
            litLastUpdated.Text = string.Format("Last updated {0:dd MMM yyyy HH:mm} by {1}",
                stamp, string.IsNullOrEmpty(who) ? "system" : who);
        }

        // Render the is_active toggle as plain HTML radio buttons.
        // Radio buttons ALWAYS post the checked value — zero ambiguity.
        string chkOn  = p.IsActive ? " checked" : "";
        string chkOff = p.IsActive ? "" : " checked";
        litActiveToggle.Text =
            "<div class='fap-toggle'>" +
            "<input type='radio' name='fap_is_active' value='yes' id='fapActiveOn' class='fap-toggle__input'" + chkOn + " />" +
            "<label for='fapActiveOn' class='fap-toggle__label fap-toggle__label--on'><span class='fap-toggle__dot'></span> Enabled</label>" +
            "<input type='radio' name='fap_is_active' value='no' id='fapActiveOff' class='fap-toggle__input'" + chkOff + " />" +
            "<label for='fapActiveOff' class='fap-toggle__label fap-toggle__label--off'><span class='fap-toggle__dot'></span> Disabled</label>" +
            "</div>";
    }

    // ─── Helpers ─────────────────────────────────────────────────────────
    private void ShowPreview(string html)
    {
        litPreview.Text = html;
        pnlPreviewResult.Visible = true;
    }

    private void ShowBanner(string message, bool success)
    {
        divResult.Attributes["class"] = success
            ? "fap-result fap-result--ok"
            : "fap-result fap-result--err";
        litResult.Text = Server.HtmlEncode(message);
    }

    private void SetDDL(System.Web.UI.WebControls.DropDownList ddl, string value)
    {
        System.Web.UI.WebControls.ListItem item = ddl.Items.FindByValue(value);
        if (item == null) return;
        ddl.ClearSelection();
        item.Selected = true;
    }

    private string CurrentUser()
    {
        if (Session["user"] != null) return Session["user"].ToString();
        if (Session["username"] != null) return Session["username"].ToString();
        return "system";
    }

    private static bool TryDec(string value, out decimal parsed)
    {
        if (string.IsNullOrEmpty(value)) { parsed = 0; return true; }
        return decimal.TryParse(value.Trim().Replace(",", ""), out parsed);
    }

    private static DateTime? ParseDateOrNull(string value)
    {
        if (string.IsNullOrEmpty(value)) return null;
        DateTime d;
        return DateTime.TryParse(value, out d) ? d.Date : (DateTime?)null;
    }
}
