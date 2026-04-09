using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class COOPERP_NewScreens_ElectionPosts : System.Web.UI.Page
{
    // ─── Page Lifecycle ──────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindGrid();
            LoadStats();
            ShowFlashMessage();
        }
    }

    // ─── Grid Binding ────────────────────────────────────────────────────────
    private void BindGrid()
    {
        DataTable dt = ElectionsHelper.GetAllPosts(false);
        StringBuilder sb = new StringBuilder();

        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='8'>");
            sb.Append("<div class='el-empty'>");
            sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='48' height='48' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><path d='M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2'/><rect x='8' y='2' width='8' height='4' rx='1' ry='1'/></svg>");
            sb.Append("<div class='el-empty__title'>No election posts defined</div>");
            sb.Append("<div class='el-empty__sub'>Click \"Add Post\" to create your first position.</div>");
            sb.Append("</div></td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow row in dt.Rows)
            {
                rowNum++;
                int id = Convert.ToInt32(row["id"]);
                string name = HttpUtility.HtmlEncode(row["post_name"].ToString());
                string code = HttpUtility.HtmlEncode(row["post_code"].ToString());
                string desc = HttpUtility.HtmlEncode((row["description"] ?? "").ToString());
                string elig = HttpUtility.HtmlEncode((row["eligibility"] ?? "").ToString());
                string resp = HttpUtility.HtmlEncode((row["responsibilities"] ?? "").ToString());
                int maxW = Convert.ToInt32(row["max_winners"]);
                int order = Convert.ToInt32(row["display_order"]);
                bool active = Convert.ToBoolean(row["is_active"]);
                int candCount = Convert.ToInt32(row["candidate_count"]);

                // Row with data attributes for JS modal pre-fill
                sb.AppendFormat("<tr data-post-id='{0}' data-name='{1}' data-code='{2}' data-desc='{3}' data-elig='{4}' data-resp='{5}' data-maxw='{6}' data-order='{7}' data-active='{8}'>",
                    id,
                    HttpUtility.HtmlAttributeEncode(row["post_name"].ToString()),
                    HttpUtility.HtmlAttributeEncode(row["post_code"].ToString()),
                    HttpUtility.HtmlAttributeEncode((row["description"] ?? "").ToString()),
                    HttpUtility.HtmlAttributeEncode((row["eligibility"] ?? "").ToString()),
                    HttpUtility.HtmlAttributeEncode((row["responsibilities"] ?? "").ToString()),
                    maxW, order, active ? "1" : "0");

                sb.AppendFormat("<td style='color:#999;'>{0}</td>", rowNum);
                sb.AppendFormat("<td><strong>{0}</strong>", name);
                if (!string.IsNullOrEmpty(desc))
                    sb.AppendFormat("<div style='font-size:10px;color:#888;margin-top:2px;'>{0}</div>", Truncate(desc, 80));
                sb.Append("</td>");
                sb.AppendFormat("<td><span class='el-post-code'>{0}</span></td>", code);
                sb.AppendFormat("<td style='text-align:center;'>{0}</td>", maxW);
                sb.AppendFormat("<td style='text-align:center;'><span class='el-badge-count'>{0}</span></td>", candCount);
                sb.AppendFormat("<td>{0}</td>",
                    active ? "<span class='el-badge-active'>Active</span>"
                           : "<span class='el-badge-inactive'>Inactive</span>");
                sb.AppendFormat("<td style='text-align:center;'>{0}</td>", order);

                sb.Append("<td>");
                sb.AppendFormat("<button type='button' class='el-btn el-btn--outline el-btn--sm' onclick='openPostModal({0});' title='Edit'>", id);
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'/><path d='M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'/></svg>");
                sb.Append("</button> ");
                sb.AppendFormat("<button type='button' class='el-btn el-btn--danger el-btn--sm' onclick=\"openDeleteModal({0}, '{1}');\" title='Delete'>",
                    id, HttpUtility.JavaScriptStringEncode(row["post_name"].ToString()));
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='3 6 5 6 21 6'/><path d='M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2'/></svg>");
                sb.Append("</button>");
                sb.Append("</td>");

                sb.Append("</tr>");
            }
        }

        litGridBody.Text = sb.ToString();
    }

    // ─── Stats ───────────────────────────────────────────────────────────────
    private void LoadStats()
    {
        DataTable dt = ElectionsHelper.GetAllPosts(false);
        litTotalPosts.Text = dt.Rows.Count.ToString();

        int active = 0;
        int totalCand = 0;
        foreach (DataRow row in dt.Rows)
        {
            if (Convert.ToBoolean(row["is_active"])) active++;
            totalCand += Convert.ToInt32(row["candidate_count"]);
        }
        litActivePosts.Text = active.ToString();
        litTotalCandidates.Text = totalCand.ToString();
    }

    // ─── Save Post ───────────────────────────────────────────────────────────
    protected void btnSavePost_Click(object sender, EventArgs e)
    {
        string name = txtPostName.Text.Trim();
        string code = txtPostCode.Text.Trim().ToUpper();

        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(code))
        {
            RedirectWithFlash("Post Name and Code are required.", false);
            return;
        }

        int id = 0;
        int.TryParse(hdnPostId.Value, out id);

        int maxW = 1;
        int.TryParse(txtMaxWinners.Text.Trim(), out maxW);
        if (maxW < 1) maxW = 1;

        int order = 0;
        int.TryParse(txtDisplayOrder.Text.Trim(), out order);

        try
        {
            ElectionsHelper.SavePost(id, name, code,
                txtDescription.Text.Trim(),
                txtEligibility.Text.Trim(),
                txtResponsibilities.Text.Trim(),
                maxW, order, chkActive.Checked);

            RedirectWithFlash(
                id > 0 ? "Post updated successfully." : "Post created successfully.",
                true);
        }
        catch (MySql.Data.MySqlClient.MySqlException ex)
        {
            if (ex.Number == 1062) // Duplicate key
                RedirectWithFlash("A post with code '" + code + "' already exists.", false);
            else
                RedirectWithFlash("Database error: " + ex.Message, false);
        }
    }

    // ─── Delete Post ─────────────────────────────────────────────────────────
    protected void btnDeletePost_Click(object sender, EventArgs e)
    {
        int id = 0;
        int.TryParse(hdnDeleteId.Value, out id);
        if (id <= 0) return;

        bool ok = ElectionsHelper.DeletePost(id);
        if (ok)
            RedirectWithFlash("Post deleted successfully.", true);
        else
            RedirectWithFlash("Cannot delete this post — it has linked candidates.", false);
    }

    // ─── Flash Message Helpers ───────────────────────────────────────────────
    private void RedirectWithFlash(string msg, bool isOk)
    {
        string url = string.Format("ElectionPosts.aspx?msg={0}&ok={1}",
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

    // ─── Utility ─────────────────────────────────────────────────────────────
    private string Truncate(string text, int max)
    {
        if (string.IsNullOrEmpty(text) || text.Length <= max) return text;
        return text.Substring(0, max) + "...";
    }
}
