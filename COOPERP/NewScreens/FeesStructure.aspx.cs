using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_FeesStructure : System.Web.UI.Page
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

    private string MainConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadProgrammeDropdowns();
            LoadYearDropdowns();

            // Default to current academic year
            string curYear = AcademicYearHelper.GetCurrentAcademicYear();
            if (ddlFSYear.Items.FindByValue(curYear) != null)
                ddlFSYear.SelectedValue = curYear;

            LoadAllPanels();
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // DROPDOWNS
    // ═══════════════════════════════════════════════════════════════════

    private void LoadProgrammeDropdowns()
    {
        using (var conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                var items = new System.Collections.Generic.List<ListItem>();
                items.Add(new ListItem("All Programmes", ""));
                while (rdr.Read())
                {
                    items.Add(new ListItem(
                        string.Format("{0} - {1}", rdr["progcode"], rdr["progname"]),
                        rdr["progcode"].ToString()));
                }
                ddlFSProg.Items.AddRange(items.ToArray());
                ddlPSProg.Items.AddRange(items.ToArray());
            }
        }
    }

    private void LoadYearDropdowns()
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT DISTINCT studsession FROM fin_fees_structure ORDER BY studsession DESC", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                ddlFSYear.Items.Clear();
                ddlFSYear.Items.Add(new ListItem("All Years", ""));
                while (rdr.Read())
                {
                    string y = rdr["studsession"].ToString();
                    ddlFSYear.Items.Add(new ListItem(y, y));
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // LOAD ALL PANELS
    // ═══════════════════════════════════════════════════════════════════

    private void LoadAllPanels()
    {
        LoadBillingItems();
        LoadFeeStructure();
        LoadPaySchedule();
        LoadBillingSystems();
    }

    // ── Billing Items ───────────────────────────────────────────────
    private void LoadBillingItems()
    {
        var sb = new StringBuilder();
        int count = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT * FROM academicbillingitems ORDER BY PriorityCode DESC, ItemCode", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    count++;
                    string priorityBadge = Convert.ToInt32(rdr["PriorityCode"]) > 0
                        ? "<span class='fs-badge fs-badge--green'>Core</span>"
                        : "<span class='fs-badge fs-badge--amber'>Optional</span>";
                    sb.AppendFormat(
                        "<tr><td><span class='fs-code'>{0}</span></td><td style='font-weight:600;'>{1}</td><td><span class='fs-code'>{2}</span></td><td>{3}</td></tr>",
                        rdr["ItemCode"], Server.HtmlEncode(rdr["ItemName"].ToString()),
                        Server.HtmlEncode(rdr["AccountCode"].ToString()), priorityBadge);
                }
            }
        }
        litBillingItems.Text = sb.ToString();
        litBillingItemCount.Text = string.Format("{0} items", count);
    }

    // ── Fee Structure ───────────────────────────────────────────────
    private void LoadFeeStructure()
    {
        string prog = ddlFSProg.SelectedValue;
        string year = ddlFSYear.SelectedValue;

        var sql = new StringBuilder(@"
            SELECT fs.ID, bi.ItemName, fs.progid, fs.studsession, fs.study_year, fs.semester, fs.amount, fs.billingID, COALESCE(bs.bs_name,'') AS bs_name
            FROM fin_fees_structure fs
            LEFT JOIN academicbillingitems bi ON bi.ItemCode=fs.ItemCode
            LEFT JOIN fin_billing_systems bs ON bs.ID=fs.billingID
            WHERE 1=1");
        if (!string.IsNullOrEmpty(prog)) sql.Append(" AND fs.progid=@prog");
        if (!string.IsNullOrEmpty(year)) sql.Append(" AND fs.studsession=@yr");
        sql.Append(" ORDER BY fs.progid, fs.study_year, fs.semester, bi.ItemName LIMIT 500");

        var rows = new StringBuilder();
        int count = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql.ToString(), conn))
            {
                if (!string.IsNullOrEmpty(prog)) cmd.Parameters.AddWithValue("@prog", prog);
                if (!string.IsNullOrEmpty(year)) cmd.Parameters.AddWithValue("@yr", year);

                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        count++;
                        double amt = Convert.ToDouble(rdr["amount"]);
                        rows.AppendFormat(
                            "<tr><td>{0}</td><td><span class='fs-code'>{1}</span></td><td>{2}</td><td>Year {3}</td><td>Sem {4}</td><td>{5}</td><td style='text-align:right' class='fs-amount'>{6:N0}</td></tr>",
                            Server.HtmlEncode(Nvl(rdr["ItemName"])),
                            Server.HtmlEncode(rdr["progid"].ToString()),
                            Server.HtmlEncode(rdr["studsession"].ToString()),
                            rdr["study_year"], rdr["semester"],
                            Server.HtmlEncode(Nvl(rdr["bs_name"])),
                            amt);
                    }
                }
            }
        }
        litStructureRows.Text = rows.ToString();
        litStructureCount.Text = string.Format("{0} entries", count);
    }

    // ── Payment Schedule ────────────────────────────────────────────
    private void LoadPaySchedule()
    {
        string prog = ddlPSProg.SelectedValue;

        var sql = new StringBuilder(@"
            SELECT ps.ID, bi.ItemName, ps.progid, ps.stud_session, ps.studyyear, ps.semester, ps.amount, ps.billingID, COALESCE(bs.bs_name,'') AS bs_name
            FROM fin_fees_pay_schedule ps
            LEFT JOIN academicbillingitems bi ON bi.ItemCode=ps.ItemID
            LEFT JOIN fin_billing_systems bs ON bs.ID=ps.billingID
            WHERE 1=1");
        if (!string.IsNullOrEmpty(prog)) sql.Append(" AND ps.progid=@prog");
        sql.Append(" ORDER BY ps.progid, ps.studyyear, ps.semester, bi.ItemName LIMIT 500");

        var rows = new StringBuilder();
        int count = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql.ToString(), conn))
            {
                if (!string.IsNullOrEmpty(prog)) cmd.Parameters.AddWithValue("@prog", prog);

                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        count++;
                        double amt = Convert.ToDouble(rdr["amount"]);
                        rows.AppendFormat(
                            "<tr><td>{0}</td><td><span class='fs-code'>{1}</span></td><td>{2}</td><td>Year {3}</td><td>Sem {4}</td><td>{5}</td><td style='text-align:right' class='fs-amount'>{6:N0}</td></tr>",
                            Server.HtmlEncode(Nvl(rdr["ItemName"])),
                            Server.HtmlEncode(rdr["progid"].ToString()),
                            Server.HtmlEncode(rdr["stud_session"].ToString()),
                            rdr["studyyear"], rdr["semester"],
                            Server.HtmlEncode(Nvl(rdr["bs_name"])),
                            amt);
                    }
                }
            }
        }
        litScheduleRows.Text = rows.ToString();
        litScheduleCount.Text = string.Format("{0} entries", count);
    }

    // ── Billing Systems ─────────────────────────────────────────────
    private void LoadBillingSystems()
    {
        var sb = new StringBuilder();
        int count = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT * FROM fin_billing_systems ORDER BY ID", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    count++;
                    sb.AppendFormat(
                        "<tr><td><span class='fs-code'>{0}</span></td><td style='font-weight:600;'>{1}</td><td>{2}</td><td><span class='fs-badge fs-badge--primary'>{3}</span></td></tr>",
                        rdr["ID"], Server.HtmlEncode(rdr["bs_name"].ToString()),
                        Server.HtmlEncode(rdr["bs_description"].ToString()),
                        Server.HtmlEncode(rdr["bs_currency"].ToString()));
                }
            }
        }
        litSystemRows.Text = sb.ToString();
        litSystemCount.Text = string.Format("{0} systems", count);
    }

    // ═══════════════════════════════════════════════════════════════════
    // EVENT HANDLERS
    // ═══════════════════════════════════════════════════════════════════

    protected void ddlFSProg_SelectedIndexChanged(object sender, EventArgs e) { LoadFeeStructure(); }
    protected void ddlFSYear_SelectedIndexChanged(object sender, EventArgs e) { LoadFeeStructure(); }
    protected void ddlPSProg_SelectedIndexChanged(object sender, EventArgs e) { LoadPaySchedule(); }

    // ═══════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════

    private string Nvl(object val)
    {
        return val == null || val == DBNull.Value ? "" : val.ToString();
    }
}
