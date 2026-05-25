using System;
using System.Text;
using System.Web;

public partial class NewScreens_TicketsController : System.Web.UI.Page
{
    protected string _statusFilter = "ALL";
    private int      _page         = 1;
    private const int PageSize     = 30;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["username"] == null)
        {
            Response.Redirect("~/Default.aspx");
            return;
        }

        SupportTicketDB.EnsureSchema();
        ReadQueryString();
        LoadStats();
        LoadTicketList();
    }

    private void ReadQueryString()
    {
        string sf = (Request.QueryString["sf"] ?? "ALL").ToUpper().Trim();
        string[] valid = { "ALL", "OPEN", "IN_PROGRESS", "AWAITING_REPLY", "RESOLVED", "CLOSED" };
        bool ok = false;
        foreach (var v in valid) if (v == sf) { ok = true; break; }
        _statusFilter = ok ? sf : "ALL";

        if (!IsPostBack)
        {
            string iss = Request.QueryString["if"] ?? "ALL";
            if (ddlIssue.Items.FindByValue(iss) != null)
                ddlIssue.SelectedValue = iss;
            txtSearch.Text = Request.QueryString["q"] ?? "";
        }

        int pg;
        _page = int.TryParse(Request.QueryString["pg"], out pg) && pg > 0 ? pg : 1;
    }

    private void LoadStats()
    {
        try
        {
            var s = SupportTicketDB.GetAdminStats();
            if (s == null) return;
            litStatTotal.Text    = S(s["total"]);
            litStatOpen.Text     = S(s["cnt_open"]);
            litStatProg.Text     = S(s["cnt_progress"]);
            litStatWait.Text     = S(s["cnt_awaiting"]);
            litStatResolved.Text = S(s["cnt_resolved"]);
            litStatClosed.Text   = S(s["cnt_closed"]);
            litStatUrgent.Text   = S(s["cnt_urgent"]);
        }
        catch { }
    }

    private void LoadTicketList()
    {
        try
        {
            string issue  = ddlIssue.SelectedValue == "ALL" ? "" : ddlIssue.SelectedValue;
            string search = txtSearch.Text.Trim();
            int offset    = (_page - 1) * PageSize;

            int total      = SupportTicketDB.CountAllTickets(_statusFilter, issue, search);
            var tickets    = SupportTicketDB.GetAllTickets(_statusFilter, issue, search, PageSize, offset);
            int totalPages = total == 0 ? 1 : (int)Math.Ceiling((double)total / PageSize);

            var sb = new StringBuilder();
            if (tickets.Rows.Count == 0)
            {
                sb.Append("<div class='tc-empty'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'>" +
                    "<circle cx='12' cy='12' r='10'/><path d='M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3'/>" +
                    "<line x1='12' y1='17' x2='12.01' y2='17'/></svg>" +
                    "No tickets found.</div>");
            }
            else
            {
                foreach (System.Data.DataRow r in tickets.Rows)
                {
                    int    id       = Convert.ToInt32(r["ticket_id"]);
                    string status   = r["status"].ToString();
                    string issue2   = r["issue_type"].ToString();
                    string subject  = HttpUtility.HtmlEncode(r["subject"].ToString());
                    string name     = HttpUtility.HtmlEncode(r["submitter_name"].ToString());
                    string regno    = HttpUtility.HtmlEncode(r["submitter_regno"].ToString());
                    string priority = r["priority"].ToString();
                    var    updated  = Convert.ToDateTime(r["updated_at"]);

                    string dotColor  = SupportTicketDB.GetIssueTypeColor(issue2);
                    string statusClr = SupportTicketDB.GetStatusColor(status);
                    string statusBg  = SupportTicketDB.GetStatusBg(status);
                    string statusLbl = SupportTicketDB.GetStatusLabel(status);
                    string tktRef    = SupportTicketDB.FormatRef(id);

                    sb.Append("<div id='row_").Append(id)
                      .Append("' class='tc-row' onclick='selectTicket(").Append(id).Append(")'>");

                    sb.Append("<div class='tc-row__top'>")
                      .Append("<span class='tc-row__ref'>").Append(tktRef).Append("</span>")
                      .Append("<span class='tc-badge' style='background:").Append(statusBg)
                      .Append(";color:").Append(statusClr).Append("'>").Append(statusLbl).Append("</span>")
                      .Append("</div>");

                    sb.Append("<div class='tc-row__subject'>").Append(subject).Append("</div>");

                    sb.Append("<div class='tc-row__meta'>")
                      .Append("<span class='tc-row__dot' style='background:").Append(dotColor).Append("'></span>")
                      .Append("<span class='tc-row__name'>").Append(name)
                      .Append(" (").Append(regno).Append(")</span>");

                    if (priority == "URGENT" || priority == "HIGH")
                        sb.Append("<span class='tc-row__urg'>").Append(HttpUtility.HtmlEncode(priority)).Append("</span>");

                    sb.Append("<span class='tc-row__ago'>").Append(SupportTicketDB.FormatTimeAgo(updated)).Append("</span>");
                    sb.Append("</div></div>");
                }
            }

            litTicketList.Text = sb.ToString();

            int from = total == 0 ? 0 : offset + 1;
            int to   = Math.Min(offset + PageSize, total);
            litPagingInfo.Text = string.Format("{0}–{1} of {2}", from, to, total);

            string baseUrl = BuildPageUrl("{0}");
            var pb = new StringBuilder();
            if (_page > 1)
                pb.AppendFormat("<a href='{0}'>&#8592;</a>", string.Format(baseUrl, _page - 1));
            for (int p = Math.Max(1, _page - 2); p <= Math.Min(totalPages, _page + 2); p++)
                pb.AppendFormat(p == _page
                    ? "<a href='#' class='is-active'>{0}</a>"
                    : "<a href='{1}'>{0}</a>", p, string.Format(baseUrl, p));
            if (_page < totalPages)
                pb.AppendFormat("<a href='{0}'>&#8594;</a>", string.Format(baseUrl, _page + 1));
            litPager.Text = pb.ToString();
        }
        catch (Exception ex)
        {
            litTicketList.Text = "<div style='padding:14px;color:#dc3545;font-size:12px;'>Error: " +
                HttpUtility.HtmlEncode(ex.Message) + "</div>";
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        Response.Redirect(BuildPageUrl("1").Replace("{0}", "1"));
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.AppRelativeCurrentExecutionFilePath);
    }

    private string BuildPageUrl(string pageToken)
    {
        return string.Format("?sf={0}&if={1}&q={2}&pg={3}",
            HttpUtility.UrlEncode(_statusFilter),
            HttpUtility.UrlEncode(ddlIssue.SelectedValue),
            HttpUtility.UrlEncode(txtSearch.Text.Trim()),
            pageToken);
    }

    private static string S(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        return val.ToString();
    }
}
