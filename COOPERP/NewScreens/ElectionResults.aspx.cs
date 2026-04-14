using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_NewScreens_ElectionResults : System.Web.UI.Page
{
    public decimal TurnoutPct { get; private set; }

    // ─── Page Lifecycle ──────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        // AJAX live results handler
        string ajax = Request.QueryString["ajax"];
        if (ajax == "liveresults")
        {
            HandleLiveResults();
            return;
        }

        if (!IsPostBack)
        {
            LoadElections();

            string eid = Request.QueryString["eid"];
            if (!string.IsNullOrEmpty(eid))
            {
                try { ddlElection.SelectedValue = eid; } catch { }
            }

            RefreshAll();
            ShowFlashMessage();
        }
        else
        {
            RecalcTurnout();
        }
    }

    // ─── AJAX Live Results ───────────────────────────────────────────────────
    private void HandleLiveResults()
    {
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);

        int eid = 0;
        int.TryParse(Request.QueryString["eid"], out eid);
        if (eid <= 0)
        {
            Response.Write("{\"ok\":false}");
            Response.End();
            return;
        }

        string json = ElectionsHelper.GetLiveVoteCountsJson(eid);
        Response.Write(json);
        Response.End();
    }

    // ─── Load Elections ──────────────────────────────────────────────────────
    private void LoadElections()
    {
        DataTable dt = ElectionsHelper.GetAllElections("");
        ddlElection.Items.Clear();
        ddlElection.Items.Add(new ListItem("-- Select Election --", "0"));
        foreach (DataRow r in dt.Rows)
        {
            string name = r["election_name"].ToString();
            string status = r["status"].ToString();
            ddlElection.Items.Add(new ListItem(
                string.Format("{0} [{1}]", name, status), r["id"].ToString()));
        }
    }

    // ─── Refresh All ─────────────────────────────────────────────────────────
    private void RefreshAll()
    {
        int eid = GetSelectedElection();
        bool hasElection = eid > 0;
        pnlNoElection.Visible = !hasElection;
        pnlContent.Visible = hasElection;

        if (!hasElection) return;

        hdnElectionId.Value = eid.ToString();

        DataRow election = ElectionsHelper.GetElection(eid);
        if (election == null) return;

        string status = election["status"].ToString();
        bool isLive = (status == "Active");
        bool isClosed = (status == "Closed");
        hdnIsLive.Value = isLive ? "1" : "0";

        // Live badge
        if (isLive)
            litLiveBadge.Text = "<span class='el-live-badge el-live-badge--active'><span class='el-live-dot'></span> LIVE</span>";
        else if (isClosed)
            litLiveBadge.Text = "<span class='el-live-badge el-live-badge--closed'>FINAL RESULTS</span>";
        else
            litLiveBadge.Text = string.Format("<span class='el-live-badge el-live-badge--off'>{0}</span>", status);

        // Compute button — show for Active/Closed (not yet computed or recomputing)
        btnCompute.Visible = (status == "Active" || status == "Closed");

        // Export button — show when results exist
        btnExportCsv.Visible = hasElection;

        // Load turnout
        LoadTurnout(eid);

        // Load results — use computed if available, otherwise live summary
        if (isClosed)
            RenderFinalResults(eid);
        else
            RenderLiveResults(eid);
    }

    private int GetSelectedElection()
    {
        int eid = 0;
        int.TryParse(ddlElection.SelectedValue, out eid);
        return eid;
    }

    // ─── Turnout ─────────────────────────────────────────────────────────────
    private void LoadTurnout(int eid)
    {
        int[] counts = ElectionsHelper.GetVoterCounts(eid);
        int total = counts[0];
        int voted = counts[1];
        TurnoutPct = total > 0 ? Math.Round((decimal)voted / total * 100, 1) : 0;
        litTurnoutPct.Text = TurnoutPct.ToString();
        litTurnoutDetail.Text = string.Format("{0} of {1} voters", voted, total);
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

    // ─── Render Live Results (from vote summary) ─────────────────────────────
    private void RenderLiveResults(int eid)
    {
        DataTable dt = ElectionsHelper.GetVoteSummary(eid);
        if (dt.Rows.Count == 0)
        {
            litResultsBody.Text =
                "<div class='el-empty'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='48' height='48' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><line x1='18' y1='20' x2='18' y2='10'/><line x1='12' y1='20' x2='12' y2='4'/><line x1='6' y1='20' x2='6' y2='14'/></svg>" +
                "<div class='el-empty__title'>No approved candidates yet</div>" +
                "<div class='el-empty__sub'>Results will appear once candidates are approved for this election.</div></div>";
            return;
        }

        StringBuilder sb = new StringBuilder();
        int lastPostId = -1;
        int totalVotesForPost = 0;
        int maxVotesForPost = 0;
        DataTable postCandidates = null;

        // Group by post and render
        for (int i = 0; i <= dt.Rows.Count; i++)
        {
            int postId = i < dt.Rows.Count ? Convert.ToInt32(dt.Rows[i]["post_id"]) : -999;

            if (postId != lastPostId)
            {
                // Render previous post
                if (postCandidates != null && postCandidates.Rows.Count > 0)
                {
                    RenderPostCard(sb, postCandidates, totalVotesForPost, maxVotesForPost, false);
                }

                if (i < dt.Rows.Count)
                {
                    lastPostId = postId;
                    postCandidates = dt.Clone();
                    totalVotesForPost = 0;
                    maxVotesForPost = 0;
                }
            }

            if (i < dt.Rows.Count)
            {
                postCandidates.ImportRow(dt.Rows[i]);
                int vc = Convert.ToInt32(dt.Rows[i]["vote_count"]);
                totalVotesForPost += vc;
                if (vc > maxVotesForPost) maxVotesForPost = vc;
            }
        }

        litResultsBody.Text = sb.ToString();
    }

    // ─── Render Final Results (from computed result table) ────────────────────
    private void RenderFinalResults(int eid)
    {
        DataTable dt = ElectionsHelper.GetResults(eid);

        if (dt.Rows.Count == 0)
        {
            // No computed results yet — fall back to live
            RenderLiveResults(eid);
            return;
        }

        StringBuilder sb = new StringBuilder();
        int lastPostId = -1;
        DataTable postRows = null;
        int totalVotesForPost = 0;

        for (int i = 0; i <= dt.Rows.Count; i++)
        {
            int postId = i < dt.Rows.Count ? Convert.ToInt32(dt.Rows[i]["post_id"]) : -999;

            if (postId != lastPostId)
            {
                if (postRows != null && postRows.Rows.Count > 0)
                    RenderFinalPostCard(sb, postRows, totalVotesForPost);

                if (i < dt.Rows.Count)
                {
                    lastPostId = postId;
                    postRows = dt.Clone();
                    totalVotesForPost = 0;
                }
            }

            if (i < dt.Rows.Count)
            {
                postRows.ImportRow(dt.Rows[i]);
                int vc = Convert.ToInt32(dt.Rows[i]["vote_count"]);
                totalVotesForPost += vc;
            }
        }

        litResultsBody.Text = sb.ToString();
    }

    // ─── Render Post Card (Live Mode) ────────────────────────────────────────
    private void RenderPostCard(StringBuilder sb, DataTable candidates, int totalVotes, int maxVotes, bool isFinal)
    {
        if (candidates.Rows.Count == 0) return;

        string postName = candidates.Rows[0]["post_name"].ToString();

        sb.Append("<div class='el-post-card'>");
        sb.AppendFormat("<div class='el-post-card__header'><div class='el-post-card__title'>" +
            "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='#174DA4' stroke-width='2'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'/><circle cx='12' cy='7' r='4'/></svg> " +
            "{0}</div><span class='el-post-card__badge'>{1} candidate(s) &bull; {2} votes</span></div>",
            HttpUtility.HtmlEncode(postName), candidates.Rows.Count, totalVotes);

        sb.Append("<div class='el-post-card__body'>");

        int rank = 0;
        foreach (DataRow row in candidates.Rows)
        {
            rank++;
            int candId = Convert.ToInt32(row["candidate_id"]);
            string candName = row["candidate_name"].ToString();
            string photoUrl = (row["photo_url"] ?? "").ToString();
            string slogan = (row["slogan"] ?? "").ToString();
            int voteCount = Convert.ToInt32(row["vote_count"]);
            decimal pct = totalVotes > 0
                ? Math.Round((decimal)voteCount / totalVotes * 100, 1) : 0;
            bool isLeading = (voteCount > 0 && voteCount == maxVotes);

            sb.AppendFormat("<div class='el-result-row{0}'>", isLeading && rank == 1 ? " el-result-row--winner" : "");

            // Rank circle
            string rankClass = rank <= 3
                ? string.Format("el-result__rank--{0}", rank)
                : "el-result__rank--other";
            sb.AppendFormat("<div class='el-result__rank {0}'>{1}</div>", rankClass, rank);

            // Photo
            if (!string.IsNullOrEmpty(photoUrl))
                sb.AppendFormat("<img class='el-result__photo' src='{0}' alt='' />",
                    HttpUtility.HtmlAttributeEncode(photoUrl));
            else
            {
                string initial = candName.Length > 0 ? candName.Substring(0, 1) : "?";
                sb.AppendFormat("<div class='el-result__photo--placeholder'>{0}</div>", initial);
            }

            // Info
            sb.Append("<div class='el-result__info'>");
            sb.AppendFormat("<div class='el-result__name'>{0}</div>", HttpUtility.HtmlEncode(candName));
            if (!string.IsNullOrEmpty(slogan))
                sb.AppendFormat("<div class='el-result__meta'>\"{0}\"</div>", HttpUtility.HtmlEncode(slogan));
            if (isLeading && rank == 1 && voteCount > 0)
                sb.Append("<span class='el-result__winner-badge'><svg xmlns='http://www.w3.org/2000/svg' width='8' height='8' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3'><polyline points='20 6 9 17 4 12'/></svg> Leading</span>");
            sb.Append("</div>");

            // Bar
            sb.Append("<div class='el-result__bar-wrap'><div class='el-result__bar'>");
            sb.AppendFormat("<div class='el-result__bar-fill {0}' id='bar_{1}' style='width:{2}%;'>",
                isLeading ? "el-result__bar-fill--lead" : "el-result__bar-fill--other",
                candId, pct);
            if (pct > 15)
                sb.AppendFormat("<span class='el-result__bar-text'>{0}%</span>", pct);
            sb.Append("</div></div></div>");

            // Votes
            sb.Append("<div class='el-result__votes'>");
            sb.AppendFormat("<div class='el-result__votes-num' id='votes_{0}'>{1}</div>", candId, voteCount);
            sb.AppendFormat("<div class='el-result__votes-pct' id='pct_{0}'>{1}%</div>", candId, pct);
            sb.Append("</div>");

            sb.Append("</div>"); // result-row
        }

        sb.Append("</div></div>"); // body + card
    }

    // ─── Render Post Card (Final Results — from elect_result) ────────────────
    private void RenderFinalPostCard(StringBuilder sb, DataTable results, int totalVotes)
    {
        if (results.Rows.Count == 0) return;

        string postName = results.Rows[0]["post_name"].ToString();

        sb.Append("<div class='el-post-card'>");
        sb.AppendFormat("<div class='el-post-card__header'><div class='el-post-card__title'>" +
            "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='#174DA4' stroke-width='2'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'/><circle cx='12' cy='7' r='4'/></svg> " +
            "{0}</div><span class='el-post-card__badge'>{1} candidate(s) &bull; {2} total votes</span></div>",
            HttpUtility.HtmlEncode(postName), results.Rows.Count, totalVotes);

        sb.Append("<div class='el-post-card__body'>");

        foreach (DataRow row in results.Rows)
        {
            int candId = Convert.ToInt32(row["candidate_id"]);
            string candName = row["candidate_name"].ToString();
            string photoUrl = (row["photo_url"] ?? "").ToString();
            string slogan = (row["slogan"] ?? "").ToString();
            string regno = (row["regno"] ?? "").ToString();
            int voteCount = Convert.ToInt32(row["vote_count"]);
            decimal pct = Convert.ToDecimal(row["percentage"]);
            int rank = Convert.ToInt32(row["rank_position"]);
            bool isWinner = Convert.ToBoolean(row["is_winner"]);
            bool isTie = Convert.ToBoolean(row["is_tie"]);

            sb.AppendFormat("<div class='el-result-row{0}'>", isWinner ? " el-result-row--winner" : "");

            // Rank circle
            string rankClass = rank <= 3
                ? string.Format("el-result__rank--{0}", rank)
                : "el-result__rank--other";
            sb.AppendFormat("<div class='el-result__rank {0}'>{1}</div>", rankClass, rank);

            // Photo
            if (!string.IsNullOrEmpty(photoUrl))
                sb.AppendFormat("<img class='el-result__photo' src='{0}' alt='' />",
                    HttpUtility.HtmlAttributeEncode(photoUrl));
            else
            {
                string initial = candName.Length > 0 ? candName.Substring(0, 1) : "?";
                sb.AppendFormat("<div class='el-result__photo--placeholder'>{0}</div>", initial);
            }

            // Info
            sb.Append("<div class='el-result__info'>");
            sb.AppendFormat("<div class='el-result__name'>{0}</div>", HttpUtility.HtmlEncode(candName));
            if (!string.IsNullOrEmpty(regno))
                sb.AppendFormat("<div class='el-result__meta'>{0}</div>", HttpUtility.HtmlEncode(regno));
            if (!string.IsNullOrEmpty(slogan))
                sb.AppendFormat("<div class='el-result__meta'>\"{0}\"</div>", HttpUtility.HtmlEncode(slogan));

            // Badges
            if (isWinner && !isTie)
                sb.Append("<span class='el-result__winner-badge'><svg xmlns='http://www.w3.org/2000/svg' width='8' height='8' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3'><polyline points='20 6 9 17 4 12'/></svg> WINNER</span>");
            if (isTie)
                sb.Append("<span class='el-result__tie-badge'><svg xmlns='http://www.w3.org/2000/svg' width='8' height='8' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3'><line x1='5' y1='12' x2='19' y2='12'/></svg> TIE</span>");
            sb.Append("</div>");

            // Bar
            sb.Append("<div class='el-result__bar-wrap'><div class='el-result__bar'>");
            sb.AppendFormat("<div class='el-result__bar-fill {0}' style='width:{1}%;'>",
                isWinner ? "el-result__bar-fill--lead" : "el-result__bar-fill--other", pct);
            if (pct > 15)
                sb.AppendFormat("<span class='el-result__bar-text'>{0}%</span>", pct);
            sb.Append("</div></div></div>");

            // Votes
            sb.Append("<div class='el-result__votes'>");
            sb.AppendFormat("<div class='el-result__votes-num'>{0}</div>", voteCount);
            sb.AppendFormat("<div class='el-result__votes-pct'>{0}%</div>", pct);
            sb.Append("</div>");

            sb.Append("</div>"); // result-row
        }

        sb.Append("</div></div>"); // body + card
    }

    // ─── Event Handlers ──────────────────────────────────────────────────────
    protected void ddlElection_Changed(object sender, EventArgs e)
    {
        RefreshAll();
    }

    protected void btnCompute_Click(object sender, EventArgs e)
    {
        int eid = GetSelectedElection();
        if (eid <= 0) return;

        try
        {
            ElectionsHelper.ComputeResults(eid);
            RedirectWithFlash("Results computed successfully.", true, "&eid=" + eid);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Error computing results: " + ex.Message, false, "&eid=" + eid);
        }
    }

    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        int eid = GetSelectedElection();
        if (eid <= 0) return;

        DataRow election = ElectionsHelper.GetElection(eid);
        string elName = election != null ? election["election_name"].ToString() : "election";

        // Try computed results first, fall back to live summary
        DataTable dt = ElectionsHelper.GetResults(eid);
        bool isFinal = dt.Rows.Count > 0;
        if (!isFinal)
            dt = ElectionsHelper.GetVoteSummary(eid);

        if (dt.Rows.Count == 0)
        {
            RedirectWithFlash("No results data to export.", false, "&eid=" + eid);
            return;
        }

        // Build CSV
        StringBuilder csv = new StringBuilder();
        csv.AppendLine("Post,Candidate,Reg No,Votes,Percentage,Rank,Winner,Tied");
        foreach (DataRow r in dt.Rows)
        {
            string postName = CsvEscape(r["post_name"].ToString());
            string candName = CsvEscape(r["candidate_name"].ToString());
            string regno = r.Table.Columns.Contains("regno") ? CsvEscape(r["regno"].ToString()) : "";
            string votes = r["vote_count"].ToString();
            string pct = isFinal && r.Table.Columns.Contains("percentage")
                ? r["percentage"].ToString() : "";
            string rank = isFinal && r.Table.Columns.Contains("rank_position")
                ? r["rank_position"].ToString() : "";
            string winner = isFinal && r.Table.Columns.Contains("is_winner")
                ? (Convert.ToInt32(r["is_winner"]) == 1 ? "Yes" : "No") : "";
            string tied = isFinal && r.Table.Columns.Contains("is_tie")
                ? (Convert.ToInt32(r["is_tie"]) == 1 ? "Yes" : "No") : "";
            csv.AppendFormat("{0},{1},{2},{3},{4},{5},{6},{7}\r\n",
                postName, candName, regno, votes, pct, rank, winner, tied);
        }

        // Send CSV
        string safeName = elName.Replace(" ", "_").Replace("\"", "");
        Response.Clear();
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition",
            string.Format("attachment; filename=\"{0}_Results.csv\"", safeName));
        Response.Write(csv.ToString());
        Response.End();
    }

    private static string CsvEscape(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        if (val.Contains(",") || val.Contains("\"") || val.Contains("\n"))
            return "\"" + val.Replace("\"", "\"\"") + "\"";
        return val;
    }

    // ─── Flash Helpers ───────────────────────────────────────────────────────
    private void RedirectWithFlash(string msg, bool isOk, string extraQs = "")
    {
        string url = string.Format("ElectionResults.aspx?msg={0}&ok={1}{2}",
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
