using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class COOPERP_NewScreens_ElectionsDashboard : System.Web.UI.Page
{
    // ─── Page Lifecycle ──────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        // Auto-transition elections based on dates
        ElectionsHelper.AutoTransitionElections();

        if (!IsPostBack)
        {
            LoadAcadYears();
            BindGrid();
            LoadStats();
            LoadActivityFeed();
            ShowFlashMessage();
        }
    }

    // ─── Lookups ─────────────────────────────────────────────────────────────
    private void LoadAcadYears()
    {
        DataTable dt = ElectionsHelper.GetAcademicYears();
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select --", ""));
        foreach (DataRow row in dt.Rows)
        {
            string yr = row["acadyear"].ToString();
            ddlAcadYear.Items.Add(new System.Web.UI.WebControls.ListItem(yr, yr));
        }
    }

    // ─── Grid Binding ────────────────────────────────────────────────────────
    private void BindGrid()
    {
        string statusFilter = ddlStatusFilter.SelectedValue;
        DataTable dt = ElectionsHelper.GetAllElections(statusFilter);

        StringBuilder sb = new StringBuilder();

        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='8'>");
            sb.Append("<div class='el-empty'>");
            sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='48' height='48' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><rect x='2' y='2' width='20' height='20' rx='2'/><path d='M9 11l3 3L22 4'/></svg>");
            sb.Append("<div class='el-empty__title'>No elections found</div>");
            sb.Append("<div class='el-empty__sub'>Click \"Create Election\" to set up your first election.</div>");
            sb.Append("</div></td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow row in dt.Rows)
            {
                rowNum++;
                int id = Convert.ToInt32(row["id"]);
                string name = row["election_name"].ToString();
                string desc = (row["description"] ?? "").ToString();
                string acadYear = (row["acad_year"] ?? "").ToString();
                string status = row["status"].ToString();
                DateTime startDate = Convert.ToDateTime(row["start_date"]);
                DateTime endDate = Convert.ToDateTime(row["end_date"]);
                int voterCount = Convert.ToInt32(row["voter_count"]);
                int votedCount = Convert.ToInt32(row["voted_count"]);
                int candCount = Convert.ToInt32(row["candidate_count"]);
                int postCount = Convert.ToInt32(row["post_count"]);

                // Turnout calculation
                decimal turnoutPct = voterCount > 0
                    ? Math.Round((decimal)votedCount / voterCount * 100, 1) : 0;

                // Data attributes for edit modal
                string startStr = startDate.ToString("yyyy-MM-ddTHH:mm");
                string endStr = endDate.ToString("yyyy-MM-ddTHH:mm");

                sb.AppendFormat("<tr data-el-id='{0}' data-name='{1}' data-desc='{2}' data-ay='{3}' data-status='{4}' data-start='{5}' data-end='{6}' data-rr='{7}' data-rfc='{8}' data-slr='{9}' data-svc='{10}' data-rp='{11}'>",
                    id,
                    HttpUtility.HtmlAttributeEncode(name),
                    HttpUtility.HtmlAttributeEncode(desc),
                    HttpUtility.HtmlAttributeEncode(acadYear),
                    status,
                    startStr, endStr,
                    row["require_registration"], row["require_fees_cleared"],
                    row["show_live_results"], row["show_vote_counts"], row["results_public"]);

                // Row number
                sb.AppendFormat("<td style='color:#999;'>{0}</td>", rowNum);

                // Election name + academic year
                sb.AppendFormat("<td><strong>{0}</strong>", HttpUtility.HtmlEncode(name));
                if (!string.IsNullOrEmpty(acadYear))
                    sb.AppendFormat("<div style='font-size:10px;color:#888;margin-top:1px;'>{0}</div>",
                        HttpUtility.HtmlEncode(acadYear));
                sb.Append("</td>");

                // Period
                sb.AppendFormat("<td><div style='font-size:11px;'>{0}</div><div style='font-size:10px;color:#888;'>to {1}</div></td>",
                    startDate.ToString("dd MMM yyyy HH:mm"),
                    endDate.ToString("dd MMM yyyy HH:mm"));

                // Status badge
                sb.AppendFormat("<td><span class='el-status el-status--{0}'>{1}</span></td>",
                    status.ToLower(), HttpUtility.HtmlEncode(status));

                // Post count
                sb.AppendFormat("<td style='text-align:center;'>{0}</td>", postCount);

                // Candidate count
                sb.AppendFormat("<td style='text-align:center;'>{0}</td>", candCount);

                // Turnout
                sb.Append("<td>");
                if (voterCount > 0)
                {
                    sb.AppendFormat("<div class='el-turnout'>" +
                        "<div class='el-turnout__bar'><div class='el-turnout__fill' style='width:{0}%'></div></div>" +
                        "<span class='el-turnout__text'>{1}/{2} ({0}%)</span></div>",
                        turnoutPct, votedCount, voterCount);
                }
                else
                {
                    sb.Append("<span style='color:#bbb; font-size:10px;'>No voters</span>");
                }
                sb.Append("</td>");

                // Actions popover
                sb.Append("<td>");
                sb.Append("<div class='el-action-wrapper'>");
                sb.Append("<button type='button' class='el-action-trigger' onclick='toggleActions(this);'>");
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='1'/><circle cx='12' cy='5' r='1'/><circle cx='12' cy='19' r='1'/></svg>");
                sb.Append("</button>");
                sb.Append("<div class='el-action-popover'><ul class='el-action-popover__menu'>");

                // Edit
                sb.AppendFormat("<li><button type='button' class='el-action-popover__btn' onclick=\"openElectionModal({0});\">", id);
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'/><path d='M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'/></svg>");
                sb.Append(" Edit</button></li>");

                // Status transitions
                sb.Append("<li class='el-action-popover__divider'></li>");
                if (status == "Draft")
                {
                    sb.AppendFormat("<li><button type='button' class='el-action-popover__btn' onclick=\"changeStatus({0},'Upcoming');\">", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='9 18 15 12 9 6'/></svg> Set Upcoming</button></li>");
                }
                if (status == "Draft" || status == "Upcoming")
                {
                    sb.AppendFormat("<li><button type='button' class='el-action-popover__btn' onclick=\"changeStatus({0},'Nominations');\">", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='8.5' cy='7' r='4'/><line x1='20' y1='8' x2='20' y2='14'/><line x1='23' y1='11' x2='17' y2='11'/></svg> Open Nominations</button></li>");
                }
                if (status == "Nominations" || status == "Upcoming")
                {
                    sb.AppendFormat("<li><button type='button' class='el-action-popover__btn' onclick=\"changeStatus({0},'Active');\">", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg> Activate Voting</button></li>");
                }
                if (status == "Active")
                {
                    sb.AppendFormat("<li><button type='button' class='el-action-popover__btn' onclick=\"changeStatus({0},'Closed');\">", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><rect x='3' y='11' width='18' height='11' rx='2' ry='2'/><path d='M7 11V7a5 5 0 0 1 10 0v4'/></svg> Close Voting</button></li>");
                }

                // Quick links
                sb.Append("<li class='el-action-popover__divider'></li>");
                sb.AppendFormat("<li><a href='ElectionCandidates.aspx?eid={0}' class='el-action-popover__btn'>", id);
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/></svg> Candidates</a></li>");
                sb.AppendFormat("<li><a href='ElectionVoters.aspx?eid={0}' class='el-action-popover__btn'>", id);
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/><line x1='19' y1='8' x2='19' y2='14'/><line x1='22' y1='11' x2='16' y2='11'/></svg> Voters</a></li>");
                sb.AppendFormat("<li><a href='ElectionResults.aspx?eid={0}' class='el-action-popover__btn'>", id);
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><line x1='18' y1='20' x2='18' y2='10'/><line x1='12' y1='20' x2='12' y2='4'/><line x1='6' y1='20' x2='6' y2='14'/></svg> Results</a></li>");

                // Delete
                sb.Append("<li class='el-action-popover__divider'></li>");
                sb.AppendFormat("<li><button type='button' class='el-action-popover__btn el-action-popover__btn--danger' onclick=\"openDeleteModal({0}, '{1}');\">",
                    id, HttpUtility.JavaScriptStringEncode(name));
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='3 6 5 6 21 6'/><path d='M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2'/></svg> Delete</button></li>");

                sb.Append("</ul></div></div>");
                sb.Append("</td>");

                sb.Append("</tr>");
            }
        }

        litGridBody.Text = sb.ToString();
    }

    // ─── Stats ───────────────────────────────────────────────────────────────
    private void LoadStats()
    {
        Dictionary<string, int> stats = ElectionsHelper.GetDashboardStats();
        litTotalElections.Text = stats.ContainsKey("total_elections") ? stats["total_elections"].ToString() : "0";
        litActiveElections.Text = stats.ContainsKey("active_elections") ? stats["active_elections"].ToString() : "0";
        litUpcomingElections.Text = stats.ContainsKey("upcoming_elections") ? stats["upcoming_elections"].ToString() : "0";
        litNominationsElections.Text = stats.ContainsKey("nominations_elections") ? stats["nominations_elections"].ToString() : "0";
        litTotalVoters.Text = stats.ContainsKey("total_voters") ? stats["total_voters"].ToString() : "0";
        litTotalCandidates.Text = stats.ContainsKey("total_candidates") ? stats["total_candidates"].ToString() : "0";

        // Second stats row
        litDraftElections.Text = stats.ContainsKey("draft_elections") ? stats["draft_elections"].ToString() : "0";
        litClosedElections.Text = stats.ContainsKey("closed_elections") ? stats["closed_elections"].ToString() : "0";
        litTotalVoted.Text = stats.ContainsKey("total_voted") ? stats["total_voted"].ToString() : "0";
        litPendingApps.Text = stats.ContainsKey("pending_applications") ? stats["pending_applications"].ToString() : "0";
    }

    // ─── Activity Feed ───────────────────────────────────────────────────────
    private void LoadActivityFeed()
    {
        DataTable dt = ElectionsHelper.GetRecentActivity();
        if (dt.Rows.Count == 0)
        {
            litActivityFeed.Text = "<div class='el-feed__empty'>No recent activity yet. Create an election to get started.</div>";
            return;
        }

        StringBuilder sb = new StringBuilder();
        foreach (DataRow row in dt.Rows)
        {
            string eventType = row["event_type"].ToString();
            string description = HttpUtility.HtmlEncode(row["description"].ToString());
            string electionName = HttpUtility.HtmlEncode(row["election_name"].ToString());
            string detail = row["detail"] != DBNull.Value ? row["detail"].ToString() : "";
            string timeAgo = "";

            if (row["timestamp"] != DBNull.Value)
            {
                DateTime ts = Convert.ToDateTime(row["timestamp"]);
                timeAgo = FormatTimeAgo(ts);
            }

            // Determine icon CSS class and SVG
            string iconClass = "el-feed__icon--election";
            string iconSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><rect x='2' y='2' width='20' height='20' rx='2'/><path d='M9 11l3 3L22 4'/></svg>";

            if (eventType == "candidate_applied")
            {
                iconClass = "el-feed__icon--candidate";
                iconSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='8.5' cy='7' r='4'/><line x1='20' y1='8' x2='20' y2='14'/><line x1='23' y1='11' x2='17' y2='11'/></svg>";
            }
            else if (eventType == "vote_cast")
            {
                iconClass = "el-feed__icon--vote";
                iconSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>";
            }

            sb.Append("<div class='el-feed__item'>");
            sb.AppendFormat("<div class='el-feed__icon {0}'>{1}</div>", iconClass, iconSvg);
            sb.Append("<div class='el-feed__body'>");
            sb.AppendFormat("<div class='el-feed__text'>{0}</div>", description);
            sb.Append("<div class='el-feed__meta'>");
            sb.AppendFormat("<span>{0}</span>", electionName);

            if (!string.IsNullOrEmpty(detail) && eventType == "candidate_applied")
            {
                sb.AppendFormat("<span class='el-feed__badge el-feed__badge--{0}'>{1}</span>",
                    detail.ToLower(), HttpUtility.HtmlEncode(detail));
            }
            else if (!string.IsNullOrEmpty(detail) && eventType == "election_updated")
            {
                sb.AppendFormat("<span class='el-feed__badge el-feed__badge--{0}'>{1}</span>",
                    detail.ToLower(), HttpUtility.HtmlEncode(detail));
            }

            if (!string.IsNullOrEmpty(timeAgo))
            {
                sb.AppendFormat("<span style='margin-left:auto;'>{0}</span>", timeAgo);
            }

            sb.Append("</div>"); // meta
            sb.Append("</div>"); // body
            sb.Append("</div>"); // item
        }

        litActivityFeed.Text = sb.ToString();
    }

    private string FormatTimeAgo(DateTime dt)
    {
        TimeSpan ts = DateTime.Now - dt;
        if (ts.TotalMinutes < 1) return "just now";
        if (ts.TotalMinutes < 60) return string.Format("{0}m ago", (int)ts.TotalMinutes);
        if (ts.TotalHours < 24) return string.Format("{0}h ago", (int)ts.TotalHours);
        if (ts.TotalDays < 7) return string.Format("{0}d ago", (int)ts.TotalDays);
        return dt.ToString("dd MMM yyyy");
    }

    // ─── Filter Changed ──────────────────────────────────────────────────────
    protected void ddlStatusFilter_Changed(object sender, EventArgs e)
    {
        BindGrid();
        LoadStats();
    }

    // ─── Save Election ───────────────────────────────────────────────────────
    protected void btnSaveElection_Click(object sender, EventArgs e)
    {
        string name = txtElectionName.Text.Trim();
        if (string.IsNullOrEmpty(name))
        {
            RedirectWithFlash("Election name is required.", false);
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate) ||
            !DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            RedirectWithFlash("Valid start and end dates are required.", false);
            return;
        }

        if (endDate <= startDate)
        {
            RedirectWithFlash("End date must be after start date.", false);
            return;
        }

        int id = 0;
        int.TryParse(hdnElectionId.Value, out id);

        string user = Session["username"] != null ? Session["username"].ToString() : "admin";

        try
        {
            ElectionsHelper.SaveElection(
                id, name, txtElectionDesc.Text.Trim(),
                ddlAcadYear.SelectedValue, startDate, endDate,
                ddlStatus.SelectedValue,
                chkRequireReg.Checked, chkRequireFees.Checked,
                "", "", // allowed programmes/entry years (future)
                chkShowLiveResults.Checked, chkShowVoteCounts.Checked,
                chkResultsPublic.Checked, user);

            RedirectWithFlash(
                id > 0 ? "Election updated successfully." : "Election created successfully.",
                true);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Error: " + ex.Message, false);
        }
    }

    // ─── Status Change ───────────────────────────────────────────────────────
    protected void btnStatusChange_Click(object sender, EventArgs e)
    {
        int id = 0;
        int.TryParse(hdnStatusId.Value, out id);
        string newStatus = hdnNewStatus.Value;

        if (id <= 0 || string.IsNullOrEmpty(newStatus)) return;

        try
        {
            ElectionsHelper.UpdateElectionStatus(id, newStatus);

            // Auto-compute results when closing
            if (newStatus == "Closed")
            {
                ElectionsHelper.ComputeResults(id);
            }

            RedirectWithFlash(
                string.Format("Election status changed to \"{0}\".", newStatus),
                true);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Error: " + ex.Message, false);
        }
    }

    // ─── Delete Election ─────────────────────────────────────────────────────
    protected void btnDeleteElection_Click(object sender, EventArgs e)
    {
        int id = 0;
        int.TryParse(hdnDeleteId.Value, out id);
        if (id <= 0) return;

        bool ok = ElectionsHelper.DeleteElection(id);
        if (ok)
            RedirectWithFlash("Election deleted successfully.", true);
        else
            RedirectWithFlash("Cannot delete this election — it has existing votes. Change status to Cancelled instead.", false);
    }

    // ─── Flash Helpers ───────────────────────────────────────────────────────
    private void RedirectWithFlash(string msg, bool isOk)
    {
        string url = string.Format("ElectionsDashboard.aspx?msg={0}&ok={1}",
            HttpUtility.UrlEncode(msg), isOk ? "1" : "0");
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
