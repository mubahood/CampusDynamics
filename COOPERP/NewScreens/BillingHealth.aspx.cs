using System;
using System.Configuration;
using System.Globalization;
using System.Text;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_BillingHealth : System.Web.UI.Page
{
    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    private string CurrentUser
    {
        get
        {
            if (Session["username"] != null && Session["username"].ToString().Trim() != "")
                return Session["username"].ToString().Trim();
            if (User != null && User.Identity != null && User.Identity.IsAuthenticated) return User.Identity.Name;
            return "system";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) LoadAll();
    }

    protected void btnRerun_Click(object sender, EventArgs e) { LoadAll(); }

    protected void btnRunNow_Click(object sender, EventArgs e)
    {
        string msg;
        try { msg = BillingReconciliationJob.RunOnce(CurrentUser); }
        catch (Exception ex) { msg = "Failed: " + ex.Message; }
        litToast.Text = "<div class='bh-toast'>" + Server.HtmlEncode(msg ?? "Done.") + "</div>";
        LoadAll();
    }

    private void LoadAll()
    {
        string year = "";
        try { year = AcademicYearHelper.GetCurrentAcademicYear(); } catch { }
        if (string.IsNullOrEmpty(year)) year = "2026/2027";
        litYear.Text = Server.HtmlEncode(year);

        RenderAudit(year, litAuditYear);
        RenderJob();
    }

    // -------- consistency audit --------
    private void RenderAudit(string scope, System.Web.UI.WebControls.Literal target)
    {
        int dbl = -1, unbilled = -1, cache = -1, orphan = -1;
        string verdict = "UNKNOWN", label = string.IsNullOrEmpty(scope) ? "All years" : scope;
        try
        {
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand("CALL fin_BillingConsistencyAudit(@ay)", conn))
                {
                    cmd.CommandTimeout = 300;
                    cmd.Parameters.AddWithValue("@ay", scope ?? "");
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            dbl = SafeInt(rd["double_bills_realitems"]);
                            unbilled = SafeInt(rd["registered_unbilled"]);
                            cache = SafeInt(rd["cache_mismatches"]);
                            orphan = SafeInt(rd["orphan_bills_unregistered"]);
                            verdict = rd["verdict"] == null || rd["verdict"] == DBNull.Value ? "UNKNOWN" : rd["verdict"].ToString();
                        }
                    }
                }
            }
        }
        catch (Exception ex) { target.Text = "<div class='bh-err'>Audit failed: " + Server.HtmlEncode(ex.Message) + "</div>"; return; }

        bool ok = verdict == "CONSISTENT";
        var sb = new StringBuilder();
        sb.Append("<div class='bh-card'>");
        sb.Append("<div class='bh-card__head'><span class='bh-card__title'>").Append(Server.HtmlEncode(label)).Append("</span>");
        sb.Append("<span class='bh-badge ").Append(ok ? "bh-badge--ok" : "bh-badge--warn").Append("'>")
          .Append(ok ? "&#10003; CONSISTENT" : "&#9888; REVIEW NEEDED").Append("</span></div>");
        sb.Append("<div class='bh-metrics'>");
        sb.Append(Metric("Double bills", dbl, dbl == 0));
        sb.Append(Metric("Registered &middot; unbilled", unbilled, unbilled == 0));
        sb.Append(Metric("Cache mismatches", cache, cache == 0));
        sb.Append(Metric("Orphan bills", orphan, orphan == 0));
        sb.Append("</div></div>");
        target.Text = sb.ToString();
    }

    private static string Metric(string label, int val, bool good)
    {
        string cls = good ? "bh-metric--good" : "bh-metric--bad";
        string v = val < 0 ? "&mdash;" : val.ToString("N0", CultureInfo.InvariantCulture);
        return "<div class='bh-metric " + cls + "'><div class='bh-metric__val'>" + v + "</div><div class='bh-metric__lbl'>" + label + "</div></div>";
    }

    // -------- reconcile job state --------
    private void RenderJob()
    {
        var sb = new StringBuilder();
        try
        {
            EnsureJobRow();
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT enabled, interval_hours, cap, status, last_run, last_finished, last_gaps, last_fixed, last_message, total_runs, total_fixed " +
                    "FROM fin_billing_recon_jobstate WHERE job_name='BILLING_RECON' LIMIT 1", conn))
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        sb.Append("<div class='bh-jobgrid'>");
                        sb.Append(Field("Status", Str(rd["status"])));
                        sb.Append(Field("Enabled", SafeInt(rd["enabled"]) == 1 ? "Yes" : "Paused"));
                        sb.Append(Field("Every", Str(rd["interval_hours"]) + " h"));
                        sb.Append(Field("Cap / run", Str(rd["cap"])));
                        sb.Append(Field("Last run", DateStr(rd["last_run"])));
                        sb.Append(Field("Last finished", DateStr(rd["last_finished"])));
                        sb.Append(Field("Last gaps", Str(rd["last_gaps"])));
                        sb.Append(Field("Last fixed", Str(rd["last_fixed"])));
                        sb.Append(Field("Total runs", Str(rd["total_runs"])));
                        sb.Append(Field("Total fixed", Str(rd["total_fixed"])));
                        sb.Append("</div>");
                        sb.Append("<div class='bh-jobmsg'>").Append(Server.HtmlEncode(Str(rd["last_message"]))).Append("</div>");
                    }
                    else sb.Append("<div class='bh-muted'>No job state yet — it initialises on the first run.</div>");
                }
            }
        }
        catch (Exception ex) { sb.Append("<div class='bh-err'>Job state unavailable: " + Server.HtmlEncode(ex.Message) + "</div>"); }
        litJob.Text = sb.ToString();
    }

    private void EnsureJobRow()
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "CREATE TABLE IF NOT EXISTS fin_billing_recon_jobstate (" +
                " job_name VARCHAR(40) NOT NULL PRIMARY KEY, enabled TINYINT(1) NOT NULL DEFAULT 1," +
                " interval_hours INT NOT NULL DEFAULT 12, cap INT NOT NULL DEFAULT 300, status VARCHAR(20) NOT NULL DEFAULT 'IDLE'," +
                " last_heartbeat DATETIME NULL, last_run DATETIME NULL, last_finished DATETIME NULL," +
                " last_acadyear VARCHAR(15) NULL, last_semester INT NOT NULL DEFAULT 0, last_gaps INT NOT NULL DEFAULT 0," +
                " last_fixed INT NOT NULL DEFAULT 0, last_message VARCHAR(500) NULL, last_error VARCHAR(500) NULL," +
                " total_runs BIGINT NOT NULL DEFAULT 0, total_fixed BIGINT NOT NULL DEFAULT 0, worker_id VARCHAR(80) NULL, updated_at DATETIME NULL" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8", conn))
            { cmd.ExecuteNonQuery(); }
            using (var cmd = new MySqlCommand(
                "INSERT IGNORE INTO fin_billing_recon_jobstate (job_name,enabled,interval_hours,cap,status) VALUES ('BILLING_RECON',1,12,300,'IDLE')", conn))
            { cmd.ExecuteNonQuery(); }
        }
    }

    private static string Field(string k, string v)
    {
        return "<div class='bh-field'><span class='bh-field__k'>" + k + "</span><span class='bh-field__v'>" + v + "</span></div>";
    }

    // -------- helpers --------
    private static int SafeInt(object o) { if (o == null || o == DBNull.Value) return -1; int v; return int.TryParse(o.ToString(), out v) ? v : (o is bool ? ((bool)o ? 1 : 0) : -1); }
    private static string Str(object o) { return (o == null || o == DBNull.Value) ? "&mdash;" : System.Web.HttpUtility.HtmlEncode(o.ToString()); }
    private static string DateStr(object o)
    {
        if (o == null || o == DBNull.Value) return "&mdash;";
        DateTime dt; return DateTime.TryParse(o.ToString(), out dt) ? dt.ToString("dd MMM yyyy HH:mm") : "&mdash;";
    }
}
