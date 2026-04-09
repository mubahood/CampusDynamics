using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_NewScreens_ElectionVoters : System.Web.UI.Page
{
    // Exposed for inline binding in ASPX turnout bar
    public decimal TurnoutPct { get; private set; }

    // ─── Page Lifecycle ──────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadElections();

            // Pre-select from query string
            string eid = Request.QueryString["eid"];
            if (!string.IsNullOrEmpty(eid))
            {
                try { ddlElection.SelectedValue = eid; }
                catch { }
            }

            LoadImportDropdowns();
            RefreshAll();
            ShowFlashMessage();
        }
        else
        {
            // Recalculate TurnoutPct on postback for inline expression
            RecalcTurnout();
        }
    }

    // ─── Load Elections ──────────────────────────────────────────────────────
    private void LoadElections()
    {
        DataTable dt = ElectionsHelper.GetAllElections("");
        ddlElection.Items.Clear();
        ddlElection.Items.Add(new ListItem("-- Select Election --", "0"));
        foreach (DataRow r in dt.Rows)
        {
            ddlElection.Items.Add(new ListItem(
                r["election_name"].ToString(), r["id"].ToString()));
        }
    }

    // ─── Import Filter Dropdowns ─────────────────────────────────────────────
    private void LoadImportDropdowns()
    {
        // Programmes
        DataTable progs = ElectionsHelper.GetProgrammes();
        ddlImportProg.Items.Clear();
        ddlImportProg.Items.Add(new ListItem("All Programmes", ""));
        foreach (DataRow r in progs.Rows)
        {
            ddlImportProg.Items.Add(new ListItem(
                r["progname"].ToString(), r["progcode"].ToString()));
        }

        // Academic years
        DataTable yrs = ElectionsHelper.GetAcademicYears();
        ddlImportYear.Items.Clear();
        ddlImportYear.Items.Add(new ListItem("All Years", ""));
        foreach (DataRow r in yrs.Rows)
        {
            string yr = r["acadyear"].ToString();
            ddlImportYear.Items.Add(new ListItem(yr, yr));
        }
    }

    // ─── Refresh Everything ──────────────────────────────────────────────────
    private void RefreshAll()
    {
        int eid = GetSelectedElection();
        bool hasElection = eid > 0;
        pnlNoElection.Visible = !hasElection;
        pnlContent.Visible = hasElection;

        if (hasElection)
        {
            BindGrid();
            LoadStats(eid);
        }
    }

    private int GetSelectedElection()
    {
        int eid = 0;
        int.TryParse(ddlElection.SelectedValue, out eid);
        return eid;
    }

    // ─── Stats & Turnout ─────────────────────────────────────────────────────
    private void LoadStats(int eid)
    {
        int[] counts = ElectionsHelper.GetVoterCounts(eid);
        int total = counts[0];
        int voted = counts[1];
        int eligible = counts[2];
        int notVoted = total - voted;
        int ineligible = total - eligible;

        litTotalVoters.Text = total.ToString();
        litVoted.Text = voted.ToString();
        litNotVoted.Text = notVoted.ToString();
        litIneligible.Text = ineligible.ToString();
        litVoterCount.Text = string.Format(
            "<span style='font-size:11px; color:#888;'>{0} voters</span>", total);

        TurnoutPct = total > 0 ? Math.Round((decimal)voted / total * 100, 1) : 0;
    }

    private void RecalcTurnout()
    {
        int eid = GetSelectedElection();
        if (eid > 0)
        {
            int[] counts = ElectionsHelper.GetVoterCounts(eid);
            TurnoutPct = counts[0] > 0
                ? Math.Round((decimal)counts[1] / counts[0] * 100, 1) : 0;
        }
    }

    // ─── Grid Binding ────────────────────────────────────────────────────────
    private void BindGrid()
    {
        int eid = GetSelectedElection();
        if (eid <= 0) return;

        string search = txtSearch.Text.Trim();
        string votedFilter = ddlVotedFilter.SelectedValue;

        DataTable dt = ElectionsHelper.GetVoters(eid, search, votedFilter);
        StringBuilder sb = new StringBuilder();

        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='8'>");
            sb.Append("<div class='el-empty'>");
            sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='48' height='48' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/></svg>");
            sb.Append("<div class='el-empty__title'>No voters found</div>");
            sb.Append("<div class='el-empty__sub'>Use the Import section above to add registered students as voters.</div>");
            sb.Append("</div></td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow row in dt.Rows)
            {
                rowNum++;
                int id = Convert.ToInt32(row["id"]);
                string regno = row["regno"].ToString();
                string name = row["voter_name"].ToString();
                string programme = (row["programme"] ?? "").ToString();
                string email = (row["email"] ?? "").ToString();
                bool hasVoted = Convert.ToBoolean(row["has_voted"]);
                bool isEligible = Convert.ToBoolean(row["is_eligible"]);
                string votedAt = "";
                if (hasVoted && row["voted_at"] != DBNull.Value)
                    votedAt = Convert.ToDateTime(row["voted_at"]).ToString("dd MMM yyyy HH:mm");

                sb.AppendFormat("<tr{0}>",
                    !isEligible ? " style='opacity:0.55;'" : "");

                // Row number
                sb.AppendFormat("<td style='color:#999;'>{0}</td>", rowNum);

                // Reg No
                sb.AppendFormat("<td><strong>{0}</strong></td>", HttpUtility.HtmlEncode(regno));

                // Name
                sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(name));

                // Programme
                sb.AppendFormat("<td style='font-size:11px;'>{0}</td>",
                    HttpUtility.HtmlEncode(programme));

                // Email
                sb.AppendFormat("<td style='font-size:11px; color:#666;'>{0}</td>",
                    HttpUtility.HtmlEncode(email));

                // Voted badge
                sb.Append("<td style='text-align:center;'>");
                if (hasVoted)
                {
                    sb.Append("<span class='el-voted el-voted--yes'>");
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3'><polyline points='20 6 9 17 4 12'/></svg> Yes</span>");
                }
                else
                {
                    sb.Append("<span class='el-voted el-voted--no'>No</span>");
                }
                sb.Append("</td>");

                // Voted at
                sb.AppendFormat("<td style='font-size:10px; color:#888;'>{0}</td>",
                    hasVoted ? votedAt : "—");

                // Eligible toggle
                sb.Append("<td style='text-align:center;'>");
                sb.AppendFormat("<label class='el-toggle'><input type='checkbox' {0} onchange=\"toggleEligibility({1}, this);\" /><span class='el-toggle__slider'></span></label>",
                    isEligible ? "checked='checked'" : "", id);
                sb.Append("</td>");

                sb.Append("</tr>");
            }
        }

        litGridBody.Text = sb.ToString();
    }

    // ─── Event Handlers ──────────────────────────────────────────────────────
    protected void ddlElection_Changed(object sender, EventArgs e)
    {
        RefreshAll();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        RefreshAll();
    }

    protected void btnImport_Click(object sender, EventArgs e)
    {
        int eid = GetSelectedElection();
        if (eid <= 0)
        {
            RedirectWithFlash("Please select an election first.", false);
            return;
        }

        try
        {
            string prog = ddlImportProg.SelectedValue;
            string year = ddlImportYear.SelectedValue;
            int count = ElectionsHelper.ImportVotersFromRegistered(eid, prog, year);

            string filterDesc = "";
            if (!string.IsNullOrEmpty(prog)) filterDesc += " from " + prog;
            if (!string.IsNullOrEmpty(year)) filterDesc += " (" + year + ")";

            RedirectWithFlash(
                string.Format("{0} voter(s) imported{1}.", count, filterDesc),
                true, "&eid=" + eid);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Import error: " + ex.Message, false, "&eid=" + eid);
        }
    }

    protected void btnToggleEligibility_Click(object sender, EventArgs e)
    {
        int voterId = 0;
        int.TryParse(hdnToggleVoterId.Value, out voterId);
        bool eligible = hdnToggleValue.Value == "1";

        if (voterId > 0)
        {
            ElectionsHelper.SetVoterEligibility(voterId, eligible);
        }

        RefreshAll();
    }

    // ─── Flash Helpers ───────────────────────────────────────────────────────
    private void RedirectWithFlash(string msg, bool isOk, string extraQs = "")
    {
        string url = string.Format("ElectionVoters.aspx?msg={0}&ok={1}{2}",
            HttpUtility.UrlEncode(msg), isOk ? "1" : "0", extraQs);
        Response.Redirect(url, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void ShowFlashMessage()
    {
        string msg = Request.QueryString["msg"];
        if (string.IsNullOrEmpty(msg)) return;

        bool isOk = Request.QueryString["ok"] == "1";
        litFlash.Text = string.Format(
            "<div class='el-flash el-flash--{0}'>" +
            "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>{1}</svg> {2}</div>",
            isOk ? "ok" : "err",
            isOk ? "<path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/>"
                 : "<circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/>",
            HttpUtility.HtmlEncode(msg));
    }
}
