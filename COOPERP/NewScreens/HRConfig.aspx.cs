using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// HRConfig — manages the single-row hrm_config table.
/// All payroll calculations (PAYE, NSSF, Kabaka, Local Tax) derive
/// their rates from this page at runtime; changes here are immediately
/// reflected the next time payroll is generated.
/// </summary>
public partial class COOPERP_NewScreens_HRConfig : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ── Default values (mirrors DB column DEFAULTs) ──────────────────────────
    private static readonly decimal D_B1_MIN  = 0m,       D_B1_MAX  = 235000m,   D_B1_RATE  = 0m;
    private static readonly decimal D_B2_MIN  = 235001m,  D_B2_MAX  = 335000m,   D_B2_RATE  = 10m;
    private static readonly decimal D_B3_MIN  = 335001m,  D_B3_MAX  = 410000m,   D_B3_RATE  = 20m;
    private static readonly decimal D_B4_MIN  = 410001m,  D_B4_MAX  = 10000000m, D_B4_RATE  = 30m;
    private static readonly decimal D_B5_MIN  = 10000001m,                        D_B5_RATE  = 40m;
    private static readonly decimal D_NSSF_EMP = 5m, D_NSSF_EMPR = 10m, D_KABAKA = 1m, D_LOCAL = 1m;

    // ─────────────────────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            LoadConfig();
    }

    // ── Load config from DB into form controls ────────────────────────────────
    private void LoadConfig()
    {
        DataTable dt;
        try
        {
            dt = ExecuteQuery("SELECT * FROM hrm_config WHERE id = 1");
        }
        catch
        {
            // Table may not exist yet; controls keep their HTML default values
            ShowBanner("hrm_config table not found. Run sql/create_hrm_config.sql first, then reload this page.", false);
            btnSave.Enabled = false;
            return;
        }

        if (dt.Rows.Count == 0) return; // DB defaults are already the HTML defaults

        DataRow r = dt.Rows[0];

        // PAYE brackets
        txtPayeB1Min.Text  = Fmt(r["paye_b1_min"]);
        txtPayeB1Max.Text  = Fmt(r["paye_b1_max"]);
        txtPayeB1Rate.Text = FmtRate(r["paye_b1_rate"]);

        txtPayeB2Min.Text  = Fmt(r["paye_b2_min"]);
        txtPayeB2Max.Text  = Fmt(r["paye_b2_max"]);
        txtPayeB2Rate.Text = FmtRate(r["paye_b2_rate"]);

        txtPayeB3Min.Text  = Fmt(r["paye_b3_min"]);
        txtPayeB3Max.Text  = Fmt(r["paye_b3_max"]);
        txtPayeB3Rate.Text = FmtRate(r["paye_b3_rate"]);

        txtPayeB4Min.Text  = Fmt(r["paye_b4_min"]);
        txtPayeB4Max.Text  = Fmt(r["paye_b4_max"]);
        txtPayeB4Rate.Text = FmtRate(r["paye_b4_rate"]);

        txtPayeB5Min.Text  = Fmt(r["paye_b5_min"]);
        txtPayeB5Max.Text  = r["paye_b5_max"] != DBNull.Value ? Fmt(r["paye_b5_max"]) : "";
        txtPayeB5Rate.Text = FmtRate(r["paye_b5_rate"]);

        // Statutory
        txtNssfEmployee.Text           = FmtRate(r["nssf_employee_rate"]);
        txtNssfEmployer.Text           = FmtRate(r["nssf_employer_rate"]);
        ddlChargeKabaka.SelectedValue  = r["should_charge_kabaka"].ToString();
        txtKabakaRate.Text             = FmtRate(r["kabaka_rate"]);

        // Local tax
        ddlChargeLocalTax.SelectedValue = r["should_charge_local_tax"].ToString();
        txtLocalTaxRate.Text            = FmtRate(r["local_tax_rate"]);

        // Leave
        txtAnnualLeave.Text    = SafeInt(r["default_annual_leave_days"]).ToString();
        txtMaternityLeave.Text = SafeInt(r["default_maternity_leave_days"]).ToString();
        txtPaternityLeave.Text = SafeInt(r["default_paternity_leave_days"]).ToString();
        txtSickLeave.Text      = SafeInt(r["default_sick_leave_days"]).ToString();

        // Policies
        ddlFYStartMonth.SelectedValue = SafeInt(r["financial_year_start_month"]).ToString();
        txtProbation.Text    = SafeInt(r["probation_period_months"]).ToString();
        txtNotice.Text       = SafeInt(r["notice_period_days"]).ToString();
        txtOvertime.Text     = r["overtime_rate_multiplier"] != DBNull.Value
                                   ? Convert.ToDecimal(r["overtime_rate_multiplier"]).ToString("0.##")
                                   : "1.5";
        txtGratuity.Text     = FmtRate(r["gratuity_rate"]);

        // Working hours
        txtWorkingDays.Text  = SafeInt(r["working_days_per_month"]).ToString();
        txtWorkingHours.Text = SafeInt(r["working_hours_per_day"]).ToString();

        // Audit banner
        if (r["last_updated"] != DBNull.Value && r["updated_by"] != DBNull.Value
            && !string.IsNullOrEmpty(r["updated_by"].ToString()))
        {
            DateTime updAt  = Convert.ToDateTime(r["last_updated"]);
            string   updBy  = r["updated_by"].ToString();
            litLastUpdated.Text    = string.Format(
                "Configuration last saved on <strong>{0}</strong> by <strong>{1}</strong>.",
                updAt.ToString("dd MMM yyyy, hh:mm tt"),
                HttpUtility.HtmlEncode(updBy));
            pnlLastUpdated.Visible = true;
        }
    }

    // ── Save ──────────────────────────────────────────────────────────────────
    protected void btnSave_Click(object sender, EventArgs e)
    {
        var errors = new List<string>();

        // ── Parse & validate PAYE brackets ──────────────────────────────────
        decimal b1min, b1max, b1rate;
        decimal        b2max, b2rate;
        decimal        b3max, b3rate;
        decimal        b4max, b4rate;
        decimal        b5rate;

        if (!TryRate(txtPayeB1Rate.Text, "Bracket 1 rate",   0,   0, errors, out b1rate))  { }
        if (!TryAmount(txtPayeB1Max.Text, "Bracket 1 Max",        errors, out b1max))       { }
        b1min = 0; // always 0

        if (!TryRate(txtPayeB2Rate.Text, "Bracket 2 rate",   0, 100, errors, out b2rate))  { }
        if (!TryAmount(txtPayeB2Max.Text, "Bracket 2 Max",        errors, out b2max))       { }

        if (!TryRate(txtPayeB3Rate.Text, "Bracket 3 rate",   0, 100, errors, out b3rate))  { }
        if (!TryAmount(txtPayeB3Max.Text, "Bracket 3 Max",        errors, out b3max))       { }

        if (!TryRate(txtPayeB4Rate.Text, "Bracket 4 rate",   0, 100, errors, out b4rate))  { }
        if (!TryAmount(txtPayeB4Max.Text, "Bracket 4 Max",        errors, out b4max))       { }

        if (!TryRate(txtPayeB5Rate.Text, "Bracket 5 rate",   0, 100, errors, out b5rate))  { }

        // Derived "Min" values for brackets 2-5 (from previous Max + 1)
        decimal b2min = 0, b3min = 0, b4min = 0, b5min = 0;
        if (errors.Count == 0)
        {
            if (b2max <= b1max) errors.Add("Bracket 2 Max must be greater than Bracket 1 Max.");
            else
            {
                b2min = b1max + 1;
                if (b3max <= b2max) errors.Add("Bracket 3 Max must be greater than Bracket 2 Max.");
                else
                {
                    b3min = b2max + 1;
                    if (b4max <= b3max) errors.Add("Bracket 4 Max must be greater than Bracket 3 Max.");
                    else
                    {
                        b4min = b3max + 1;
                        b5min = b4max + 1;
                    }
                }
            }
        }

        // ── Parse & validate statutory rates ────────────────────────────────
        decimal nssfEmp, nssfEmpr, kabakaRate, localRate;
        if (!TryRate(txtNssfEmployee.Text, "Employee NSSF rate", 0, 50,  errors, out nssfEmp))   { }
        if (!TryRate(txtNssfEmployer.Text, "Employer NSSF rate", 0, 50,  errors, out nssfEmpr))  { }
        if (!TryRate(txtKabakaRate.Text,   "Kabaka rate",        0, 20,  errors, out kabakaRate)) { }
        if (!TryRate(txtLocalTaxRate.Text, "Local tax rate",     0, 20,  errors, out localRate))  { }

        string chargeKabaka   = ddlChargeKabaka.SelectedValue;
        string chargeLocalTax = ddlChargeLocalTax.SelectedValue;
        if (chargeKabaka   != "Yes" && chargeKabaka   != "No") errors.Add("Invalid Kabaka charge flag.");
        if (chargeLocalTax != "Yes" && chargeLocalTax != "No") errors.Add("Invalid local tax flag.");

        // ── Leave ────────────────────────────────────────────────────────────
        int annualLeave, maternityLeave, paternityLeave, sickLeave;
        if (!TryDays(txtAnnualLeave.Text,    "Annual leave",    1, 365, errors, out annualLeave))    { }
        if (!TryDays(txtMaternityLeave.Text, "Maternity leave", 1, 365, errors, out maternityLeave)) { }
        if (!TryDays(txtPaternityLeave.Text, "Paternity leave", 0, 365, errors, out paternityLeave)) { }
        if (!TryDays(txtSickLeave.Text,      "Sick leave",      0, 365, errors, out sickLeave))      { }

        // ── Policies ─────────────────────────────────────────────────────────
        int fyMonth, probation, noticeDays, workDays, workHours;
        decimal overtime, gratuity;

        if (!int.TryParse(ddlFYStartMonth.SelectedValue, out fyMonth) || fyMonth < 1 || fyMonth > 12)
            errors.Add("Invalid financial year start month.");

        if (!TryDays(txtProbation.Text, "Probation (months)", 0, 12, errors, out probation))  { }
        if (!TryDays(txtNotice.Text,    "Notice period",      0, 365, errors, out noticeDays)) { }
        if (!TryDays(txtWorkingDays.Text, "Working days/month", 1, 31, errors, out workDays))  { }
        if (!TryDays(txtWorkingHours.Text,"Working hours/day",  1, 24, errors, out workHours)) { }

        if (!decimal.TryParse(txtOvertime.Text, out overtime) || overtime < 1m || overtime > 10m)
            errors.Add("Overtime multiplier must be between 1.0 and 10.0.");
        if (!TryRate(txtGratuity.Text, "Gratuity rate", 0, 100, errors, out gratuity)) { }

        // ── Abort on validation errors ───────────────────────────────────────
        if (errors.Count > 0)
        {
            ShowBanner("Please fix the following: " + string.Join(" | ", errors), false);
            return;
        }

        // ── Upsert (replace the single row) ─────────────────────────────────
        string user = (HttpContext.Current.Session["ScreenName"] ?? "").ToString();
        if (string.IsNullOrEmpty(user))
            user = (HttpContext.Current.Session["username"] ?? "System").ToString();

        try
        {
            ExecuteNonQuery(@"
                INSERT INTO hrm_config (
                    id,
                    paye_b1_min, paye_b1_max, paye_b1_rate,
                    paye_b2_min, paye_b2_max, paye_b2_rate,
                    paye_b3_min, paye_b3_max, paye_b3_rate,
                    paye_b4_min, paye_b4_max, paye_b4_rate,
                    paye_b5_min, paye_b5_max, paye_b5_rate,
                    nssf_employee_rate, nssf_employer_rate,
                    should_charge_kabaka, kabaka_rate,
                    should_charge_local_tax, local_tax_rate,
                    default_annual_leave_days, default_maternity_leave_days,
                    default_paternity_leave_days, default_sick_leave_days,
                    financial_year_start_month,
                    probation_period_months, notice_period_days,
                    overtime_rate_multiplier, gratuity_rate,
                    working_days_per_month, working_hours_per_day,
                    last_updated, updated_by
                ) VALUES (
                    1,
                    @b1min,@b1max,@b1rate,
                    @b2min,@b2max,@b2rate,
                    @b3min,@b3max,@b3rate,
                    @b4min,@b4max,@b4rate,
                    @b5min,NULL,@b5rate,
                    @nssfEmp,@nssfEmpr,
                    @chargeKabaka,@kabakaRate,
                    @chargeLocal,@localRate,
                    @annLeave,@matLeave,@patLeave,@sickLeave,
                    @fyMonth,
                    @probation,@notice,
                    @overtime,@gratuity,
                    @workDays,@workHours,
                    @now,@user
                )
                ON DUPLICATE KEY UPDATE
                    paye_b1_min=@b1min, paye_b1_max=@b1max, paye_b1_rate=@b1rate,
                    paye_b2_min=@b2min, paye_b2_max=@b2max, paye_b2_rate=@b2rate,
                    paye_b3_min=@b3min, paye_b3_max=@b3max, paye_b3_rate=@b3rate,
                    paye_b4_min=@b4min, paye_b4_max=@b4max, paye_b4_rate=@b4rate,
                    paye_b5_min=@b5min, paye_b5_max=NULL,   paye_b5_rate=@b5rate,
                    nssf_employee_rate=@nssfEmp, nssf_employer_rate=@nssfEmpr,
                    should_charge_kabaka=@chargeKabaka, kabaka_rate=@kabakaRate,
                    should_charge_local_tax=@chargeLocal, local_tax_rate=@localRate,
                    default_annual_leave_days=@annLeave, default_maternity_leave_days=@matLeave,
                    default_paternity_leave_days=@patLeave, default_sick_leave_days=@sickLeave,
                    financial_year_start_month=@fyMonth,
                    probation_period_months=@probation, notice_period_days=@notice,
                    overtime_rate_multiplier=@overtime, gratuity_rate=@gratuity,
                    working_days_per_month=@workDays, working_hours_per_day=@workHours,
                    last_updated=@now, updated_by=@user",
                P("@b1min",   b1min),   P("@b1max",   b1max),   P("@b1rate",   b1rate),
                P("@b2min",   b2min),   P("@b2max",   b2max),   P("@b2rate",   b2rate),
                P("@b3min",   b3min),   P("@b3max",   b3max),   P("@b3rate",   b3rate),
                P("@b4min",   b4min),   P("@b4max",   b4max),   P("@b4rate",   b4rate),
                P("@b5min",   b5min),                            P("@b5rate",   b5rate),
                P("@nssfEmp", nssfEmp), P("@nssfEmpr", nssfEmpr),
                P("@chargeKabaka", chargeKabaka), P("@kabakaRate", kabakaRate),
                P("@chargeLocal",  chargeLocalTax),P("@localRate",  localRate),
                P("@annLeave",  annualLeave),  P("@matLeave",  maternityLeave),
                P("@patLeave",  paternityLeave), P("@sickLeave", sickLeave),
                P("@fyMonth",   fyMonth),
                P("@probation", probation),    P("@notice",    noticeDays),
                P("@overtime",  overtime),     P("@gratuity",  gratuity),
                P("@workDays",  workDays),     P("@workHours", workHours),
                P("@now",  DateTime.Now),      P("@user", user));

            ShowBanner("Configuration saved successfully. Payroll calculations will use the new rates from the next run.", true);
            LoadConfig(); // refresh audit banner
        }
        catch (Exception ex)
        {
            ShowBanner("Save failed: " + ex.Message, false);
        }
    }

    // ── Reset to factory defaults ─────────────────────────────────────────────
    protected void btnReset_Click(object sender, EventArgs e)
    {
        string user = (HttpContext.Current.Session["ScreenName"] ?? "").ToString();
        if (string.IsNullOrEmpty(user))
            user = (HttpContext.Current.Session["username"] ?? "System").ToString();

        try
        {
            ExecuteNonQuery(@"
                INSERT INTO hrm_config (id) VALUES (1)
                ON DUPLICATE KEY UPDATE
                    paye_b1_min=0,      paye_b1_max=235000,    paye_b1_rate=0,
                    paye_b2_min=235001, paye_b2_max=335000,    paye_b2_rate=10,
                    paye_b3_min=335001, paye_b3_max=410000,    paye_b3_rate=20,
                    paye_b4_min=410001, paye_b4_max=10000000,  paye_b4_rate=30,
                    paye_b5_min=10000001,paye_b5_max=NULL,     paye_b5_rate=40,
                    nssf_employee_rate=5, nssf_employer_rate=10,
                    should_charge_kabaka='Yes', kabaka_rate=1,
                    should_charge_local_tax='No', local_tax_rate=1,
                    default_annual_leave_days=30, default_maternity_leave_days=60,
                    default_paternity_leave_days=4, default_sick_leave_days=30,
                    financial_year_start_month=7,
                    probation_period_months=3, notice_period_days=30,
                    overtime_rate_multiplier=1.5, gratuity_rate=5,
                    working_days_per_month=22, working_hours_per_day=8,
                    last_updated=@now, updated_by=@user",
                P("@now",  DateTime.Now),
                P("@user", user));

            ShowBanner("All settings have been reset to factory defaults.", true);
            LoadConfig();
        }
        catch (Exception ex)
        {
            ShowBanner("Reset failed: " + ex.Message, false);
        }
    }

    // ── Validation helpers ────────────────────────────────────────────────────
    private bool TryRate(string raw, string label, decimal min, decimal max,
                         List<string> errors, out decimal result)
    {
        result = 0;
        if (!decimal.TryParse(raw.Trim(), out result))
        {
            errors.Add(label + " must be a valid number.");
            return false;
        }
        if (result < min || result > max)
        {
            errors.Add(string.Format("{0} must be between {1} and {2}.", label, min, max));
            return false;
        }
        return true;
    }

    private bool TryAmount(string raw, string label, List<string> errors, out decimal result)
    {
        result = 0;
        if (!decimal.TryParse(raw.Trim(), out result) || result < 0)
        {
            errors.Add(label + " must be a valid non-negative number.");
            return false;
        }
        return true;
    }

    private bool TryDays(string raw, string label, int min, int max,
                         List<string> errors, out int result)
    {
        result = 0;
        if (!int.TryParse(raw.Trim(), out result) || result < min || result > max)
        {
            errors.Add(string.Format("{0} must be a whole number between {1} and {2}.", label, min, max));
            return false;
        }
        return true;
    }

    // ── Display helpers ───────────────────────────────────────────────────────
    private void ShowBanner(string message, bool success)
    {
        string css = success ? "hrc-result hrc-result--ok" : "hrc-result hrc-result--err";
        divResult.Attributes["class"] = css;
        litResult.Text = HttpUtility.HtmlEncode(message);

        ScriptManager.RegisterStartupScript(this, GetType(), "scrollTop",
            "window.scrollTo({top:0,behavior:'smooth'});", true);
    }

    private string Fmt(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d.ToString("0.##") : val.ToString();
    }

    private string FmtRate(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d.ToString("0.##") : "0";
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int i;
        return int.TryParse(val.ToString(), out i) ? i : 0;
    }

    // ── DB helpers ────────────────────────────────────────────────────────────
    private static MySqlParameter P(string name, object value)
    {
        return new MySqlParameter(name, value ?? DBNull.Value);
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
