using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_NewScreens_ElectionCandidates : System.Web.UI.Page
{
    // ─── Page Lifecycle ──────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX student search
        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        Page.Form.Enctype = "multipart/form-data";

        if (!IsPostBack)
        {
            LoadDropdowns();

            // If coming from dashboard with pre-selected election
            string eid = Request.QueryString["eid"];
            if (!string.IsNullOrEmpty(eid))
            {
                try { ddlElection.SelectedValue = eid; } catch { }
            }

            BindGrid();
            LoadStats();
            ShowFlashMessage();
        }
    }

    // ─── AJAX Handler ────────────────────────────────────────────────────────
    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);

        if (action == "searchstudent")
        {
            string q = Request.QueryString["q"];
            if (string.IsNullOrEmpty(q) || q.Length < 2)
            {
                Response.Write("[]");
                Response.End();
                return;
            }

            DataTable dt = ElectionsHelper.SearchStudents(q);
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i > 0) sb.Append(",");
                sb.AppendFormat("{{\"regno\":\"{0}\",\"name\":\"{1}\",\"prog\":\"{2}\"}}",
                    EscapeJson(dt.Rows[i]["regno"].ToString()),
                    EscapeJson(dt.Rows[i]["firstname"].ToString() + " " + dt.Rows[i]["othername"].ToString()),
                    EscapeJson(dt.Rows[i]["progname"].ToString()));
            }
            sb.Append("]");
            Response.Write(sb.ToString());
            Response.End();
        }
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
    }

    // ─── Dropdowns ───────────────────────────────────────────────────────────
    private void LoadDropdowns()
    {
        // Elections (filter + modal)
        DataTable elections = ElectionsHelper.GetAllElections("");
        ddlElection.Items.Clear();
        ddlElection.Items.Add(new ListItem("All Elections", "0"));
        ddlModalElection.Items.Clear();
        ddlModalElection.Items.Add(new ListItem("-- Select Election --", "0"));
        foreach (DataRow r in elections.Rows)
        {
            string id = r["id"].ToString();
            string name = r["election_name"].ToString();
            ddlElection.Items.Add(new ListItem(name, id));
            ddlModalElection.Items.Add(new ListItem(name, id));
        }

        // Posts (filter + modal)
        DataTable posts = ElectionsHelper.GetAllPosts(true);
        ddlPost.Items.Clear();
        ddlPost.Items.Add(new ListItem("All Posts", "0"));
        ddlModalPost.Items.Clear();
        ddlModalPost.Items.Add(new ListItem("-- Select Post --", "0"));
        foreach (DataRow r in posts.Rows)
        {
            string id = r["id"].ToString();
            string name = r["post_name"].ToString();
            ddlPost.Items.Add(new ListItem(name, id));
            ddlModalPost.Items.Add(new ListItem(name, id));
        }
    }

    // ─── Grid Binding ────────────────────────────────────────────────────────
    private void BindGrid()
    {
        int electionId = 0;
        int.TryParse(ddlElection.SelectedValue, out electionId);
        int postId = 0;
        int.TryParse(ddlPost.SelectedValue, out postId);
        string statusFilter = ddlStatusFilter.SelectedValue;
        string search = txtSearch.Text.Trim();

        DataTable dt = ElectionsHelper.GetCandidates(electionId, postId, statusFilter, search);

        StringBuilder sb = new StringBuilder();

        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='8'>");
            sb.Append("<div class='el-empty'>");
            sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='48' height='48' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/><line x1='19' y1='8' x2='19' y2='14'/><line x1='22' y1='11' x2='16' y2='11'/></svg>");
            sb.Append("<div class='el-empty__title'>No candidates found</div>");
            sb.Append("<div class='el-empty__sub'>Add candidates using the button above or adjust filters.</div>");
            sb.Append("</div></td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow row in dt.Rows)
            {
                rowNum++;
                int id = Convert.ToInt32(row["id"]);
                string name = row["candidate_name"].ToString();
                string regno = row["regno"].ToString();
                string slogan = (row["slogan"] ?? "").ToString();
                string manifesto = (row["manifesto"] ?? "").ToString();
                string status = row["status"].ToString();
                string postName = row["post_name"].ToString();
                string postCode = row["post_code"].ToString();
                string elName = row["election_name"].ToString();
                int elId = Convert.ToInt32(row["election_id"]);
                int pId = Convert.ToInt32(row["post_id"]);
                int voteCount = Convert.ToInt32(row["vote_count"]);
                string photoUrl = (row["photo_url"] ?? "").ToString();
                string reason = (row["rejection_reason"] ?? "").ToString();

                // Data attributes for JS edit pre-fill
                string rowStyle = status == "Pending"
                    ? " style='border-left:3px solid #e67e00;background:#fffdf5;'"
                    : "";
                sb.AppendFormat("<tr data-cid='{0}' data-name='{1}' data-regno='{2}' data-slogan='{3}' data-manifesto='{4}' data-cstatus='{5}' data-eid='{6}' data-pid='{7}' data-photo='{8}'{9}>",
                    id,
                    HttpUtility.HtmlAttributeEncode(name),
                    HttpUtility.HtmlAttributeEncode(regno),
                    HttpUtility.HtmlAttributeEncode(slogan),
                    HttpUtility.HtmlAttributeEncode(manifesto),
                    status, elId, pId,
                    HttpUtility.HtmlAttributeEncode(photoUrl),
                    rowStyle);

                // Checkbox
                sb.AppendFormat("<td style='text-align:center;'><input type='checkbox' class='cand-chk' value='{0}' onchange='updateCandBatchBar()' /></td>", id);

                // Row number
                sb.AppendFormat("<td style='color:#999;'>{0}</td>", rowNum);

                // Candidate card cell
                sb.Append("<td><div class='el-cand'>");
                if (!string.IsNullOrEmpty(photoUrl))
                {
                    sb.AppendFormat("<img class='el-cand__photo' src='{0}' alt='' />",
                        HttpUtility.HtmlAttributeEncode(photoUrl));
                }
                else
                {
                    // Initial avatar
                    string initial = name.Length > 0 ? name.Substring(0, 1) : "?";
                    sb.AppendFormat("<div class='el-cand__photo--placeholder'>{0}</div>", initial);
                }
                sb.Append("<div class='el-cand__info'>");
                sb.AppendFormat("<div class='el-cand__name'>{0}</div>", HttpUtility.HtmlEncode(name));
                sb.AppendFormat("<div class='el-cand__regno'>{0}</div>", HttpUtility.HtmlEncode(regno));
                if (!string.IsNullOrEmpty(slogan))
                    sb.AppendFormat("<div class='el-cand__slogan'>\"{0}\"</div>", HttpUtility.HtmlEncode(slogan));
                sb.Append("</div></div></td>");

                // Post
                sb.AppendFormat("<td><strong>{0}</strong><div style='font-size:10px;color:#888;'>{1}</div></td>",
                    HttpUtility.HtmlEncode(postName), HttpUtility.HtmlEncode(postCode));

                // Election
                sb.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(elName));

                // Status badge
                sb.AppendFormat("<td><span class='el-status el-status--{0}'>{1}</span>",
                    status.ToLower(), HttpUtility.HtmlEncode(status));
                if (!string.IsNullOrEmpty(reason))
                    sb.AppendFormat("<div style='font-size:9px;color:#999;margin-top:2px;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;' title='{0}'>Reason: {0}</div>",
                        HttpUtility.HtmlAttributeEncode(reason));
                sb.Append("</td>");

                // Votes
                sb.AppendFormat("<td style='text-align:center; font-weight:600;'>{0}</td>", voteCount);

                // Actions
                sb.Append("<td><div class='el-actions-row'>");

                // Edit button
                sb.AppendFormat("<button type='button' class='el-btn el-btn--outline el-btn--xs' onclick='openCandidateModal({0});' title='Edit'>", id);
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'/><path d='M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'/></svg></button>");

                // Status actions
                if (status == "Pending")
                {
                    sb.AppendFormat("<button type='button' class='el-btn el-btn--success el-btn--xs' onclick=\"openStatusModal({0},'Approved');\" title='Approve'>", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='20 6 9 17 4 12'/></svg></button>");

                    sb.AppendFormat("<button type='button' class='el-btn el-btn--danger el-btn--xs' onclick=\"openStatusModal({0},'Rejected');\" title='Reject'>", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><line x1='18' y1='6' x2='6' y2='18'/><line x1='6' y1='6' x2='18' y2='18'/></svg></button>");
                }
                if (status == "Approved")
                {
                    sb.AppendFormat("<button type='button' class='el-btn el-btn--danger el-btn--xs' onclick=\"openStatusModal({0},'Disqualified');\" title='Disqualify'>", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='4.93' y1='4.93' x2='19.07' y2='19.07'/></svg></button>");
                }
                if (status == "Rejected" || status == "Disqualified")
                {
                    sb.AppendFormat("<button type='button' class='el-btn el-btn--outline el-btn--xs' onclick=\"openStatusModal({0},'Pending');\" title='Reset to Pending'>", id);
                    sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='1 4 1 10 7 10'/><path d='M3.51 15a9 9 0 1 0 2.13-9.36L1 10'/></svg></button>");
                }

                // Delete
                sb.AppendFormat("<button type='button' class='el-btn el-btn--outline el-btn--xs' onclick=\"openDeleteModal({0}, '{1}');\" title='Delete' style='color:#dc3545;border-color:#ecc;'>",
                    id, HttpUtility.JavaScriptStringEncode(name));
                sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='3 6 5 6 21 6'/><path d='M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2'/></svg></button>");

                sb.Append("</div></td>");
                sb.Append("</tr>");
            }
        }

        litGridBody.Text = sb.ToString();
    }

    // ─── Stats ───────────────────────────────────────────────────────────────
    private void LoadStats()
    {
        int electionId = 0;
        int.TryParse(ddlElection.SelectedValue, out electionId);
        int postId = 0;
        int.TryParse(ddlPost.SelectedValue, out postId);

        // Get all candidates for the current filter (no status filter for stats)
        DataTable dt = ElectionsHelper.GetCandidates(electionId, postId, "ALL");

        int total = dt.Rows.Count;
        int approved = 0, pending = 0, rejectedDq = 0;
        foreach (DataRow row in dt.Rows)
        {
            string st = row["status"].ToString();
            if (st == "Approved") approved++;
            else if (st == "Pending") pending++;
            else rejectedDq++;
        }

        litTotalCandidates.Text = total.ToString();
        litApproved.Text = approved.ToString();
        litPending.Text = pending.ToString();
        litRejected.Text = rejectedDq.ToString();

        // Show pending self-nominations banner
        if (pending > 0)
        {
            pnlPendingBanner.Visible = true;
            litPendingCount.Text = pending.ToString();

            // Build a short summary of which elections have pending candidates
            Dictionary<string, int> pendingByElection = new Dictionary<string, int>();
            foreach (DataRow row in dt.Rows)
            {
                if (row["status"].ToString() == "Pending")
                {
                    string eName = row["election_name"].ToString();
                    if (pendingByElection.ContainsKey(eName))
                        pendingByElection[eName]++;
                    else
                        pendingByElection[eName] = 1;
                }
            }
            StringBuilder detail = new StringBuilder();
            foreach (KeyValuePair<string, int> kv in pendingByElection)
            {
                if (detail.Length > 0) detail.Append(", ");
                detail.AppendFormat("{0} ({1})", Server.HtmlEncode(kv.Key), kv.Value);
            }
            if (detail.Length > 0)
                litPendingDetail.Text = string.Format("Elections: {0}", detail.ToString());
        }
        else
        {
            pnlPendingBanner.Visible = false;
        }
    }

    // ─── Filter Changed ──────────────────────────────────────────────────────
    protected void ddlFilter_Changed(object sender, EventArgs e)
    {
        BindGrid();
        LoadStats();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid();
        LoadStats();
    }

    // ─── Save Candidate ──────────────────────────────────────────────────────
    protected void btnSaveCandidate_Click(object sender, EventArgs e)
    {
        string regno = hdnRegno.Value.Trim();
        string candName = hdnCandidateName.Value.Trim();

        if (string.IsNullOrEmpty(regno))
        {
            RedirectWithFlash("Please search and select a student.", false);
            return;
        }

        int electionId = 0;
        // JS sets modal dropdowns client-side; read directly from POST data for reliability
        string rawEid = Request.Form[ddlModalElection.UniqueID];
        if (string.IsNullOrEmpty(rawEid)) rawEid = ddlModalElection.SelectedValue;
        int.TryParse(rawEid, out electionId);
        if (electionId <= 0)
        {
            RedirectWithFlash("Please select an election.", false);
            return;
        }

        int postId = 0;
        string rawPid = Request.Form[ddlModalPost.UniqueID];
        if (string.IsNullOrEmpty(rawPid)) rawPid = ddlModalPost.SelectedValue;
        int.TryParse(rawPid, out postId);
        if (postId <= 0)
        {
            RedirectWithFlash("Please select a post/position.", false);
            return;
        }

        int candId = 0;
        int.TryParse(hdnCandidateId.Value, out candId);

        try
        {
            // Handle optional photo upload
            string newPhotoUrl = "";
            HttpPostedFile photoFile = Request.Files["fuCandPhoto"];
            if (photoFile != null && photoFile.ContentLength > 0)
            {
                string ext = System.IO.Path.GetExtension(photoFile.FileName).ToLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif" || ext == ".webp")
                {
                    try
                    {
                        string uploadDir = Server.MapPath("~/Data_Uploads/Elections/");
                        if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
                        string baseName = Regex.Replace(
                            Path.GetFileNameWithoutExtension(photoFile.FileName), @"[^a-zA-Z0-9_\-]", "_");
                        string fname = string.Format("{0}_{1}_{2}{3}",
                            Regex.Replace(regno, @"[^a-zA-Z0-9]", ""),
                            baseName, DateTime.Now.Ticks, ext);
                        photoFile.SaveAs(Path.Combine(uploadDir, fname));
                        newPhotoUrl = "https://eadmin.mru.ac.ug/Data_Uploads/Elections/" + fname;
                    }
                    catch { /* non-fatal: continue without updating photo */ }
                }
            }

            // If no new photo uploaded, keep existing photo (from hidden field)
            string photoUrl = !string.IsNullOrEmpty(newPhotoUrl)
                ? newPhotoUrl
                : hdnCandPhotoUrl.Value.Trim();

            ElectionsHelper.SaveCandidate(
                candId, electionId, postId, regno, candName,
                photoUrl,
                txtManifesto.Text.Trim(),
                txtSlogan.Text.Trim(),
                Request.Form[ddlModalStatus.UniqueID] ?? ddlModalStatus.SelectedValue);

            string qs = ddlElection.SelectedValue != "0"
                ? "&eid=" + ddlElection.SelectedValue : "";

            RedirectWithFlash(
                candId > 0 ? "Candidate updated successfully." : "Candidate added successfully.",
                true, qs);
        }
        catch (MySql.Data.MySqlClient.MySqlException mex)
        {
            if (mex.Number == 1062) // duplicate key
                RedirectWithFlash("This student is already a candidate for this post in this election.", false);
            else
                RedirectWithFlash("Error: " + mex.Message, false);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Error: " + ex.Message, false);
        }
    }

    // ─── Status Change ───────────────────────────────────────────────────────
    protected void btnStatusChange_Click(object sender, EventArgs e)
    {
        int candId = 0;
        int.TryParse(hdnStatusCandId.Value, out candId);
        string newStatus = hdnNewStatus.Value;

        if (candId <= 0 || string.IsNullOrEmpty(newStatus)) return;

        try
        {
            ElectionsHelper.UpdateCandidateStatus(candId, newStatus, txtStatusReason.Text.Trim());

            string qs = ddlElection.SelectedValue != "0"
                ? "&eid=" + ddlElection.SelectedValue : "";

            RedirectWithFlash(
                string.Format("Candidate status changed to \"{0}\".", newStatus),
                true, qs);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Error: " + ex.Message, false);
        }
    }

    // ─── Delete Candidate ────────────────────────────────────────────────────
    protected void btnDeleteCandidate_Click(object sender, EventArgs e)
    {
        int candId = 0;
        int.TryParse(hdnDeleteId.Value, out candId);
        if (candId <= 0) return;

        try
        {
            bool ok = ElectionsHelper.DeleteCandidate(candId);
            string qs = ddlElection.SelectedValue != "0"
                ? "&eid=" + ddlElection.SelectedValue : "";

            if (ok)
                RedirectWithFlash("Candidate removed successfully.", true, qs);
            else
                RedirectWithFlash("Cannot delete this candidate — they already have votes. Disqualify instead.", false, qs);
        }
        catch (Exception ex)
        {
            RedirectWithFlash("Error: " + ex.Message, false);
        }
    }

    // ─── Batch Handlers ──────────────────────────────────────────────────────
    private static int[] ParseIds(string csv)
    {
        if (string.IsNullOrEmpty(csv)) return new int[0];
        string[] parts = csv.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);
        System.Collections.Generic.List<int> list = new System.Collections.Generic.List<int>();
        foreach (string p in parts)
        {
            int n;
            if (int.TryParse(p.Trim(), out n)) list.Add(n);
        }
        return list.ToArray();
    }

    protected void btnBatchCandApprove_Click(object sender, EventArgs e)
    {
        int[] ids = ParseIds(hdnBatchCandIds.Value);
        if (ids.Length == 0) { BindGrid(); return; }
        int updated = ElectionsHelper.BatchUpdateCandidateStatus(ids, "Approved", "");
        string qs = ddlElection.SelectedValue != "0" ? "&eid=" + ddlElection.SelectedValue : "";
        RedirectWithFlash(string.Format("{0} candidate(s) approved.", updated), true, qs);
    }

    protected void btnBatchCandReject_Click(object sender, EventArgs e)
    {
        int[] ids = ParseIds(hdnBatchCandIds.Value);
        if (ids.Length == 0) { BindGrid(); return; }
        int updated = ElectionsHelper.BatchUpdateCandidateStatus(ids, "Rejected", "");
        string qs = ddlElection.SelectedValue != "0" ? "&eid=" + ddlElection.SelectedValue : "";
        RedirectWithFlash(string.Format("{0} candidate(s) rejected.", updated), true, qs);
    }

    protected void btnBatchCandDisqualify_Click(object sender, EventArgs e)
    {
        int[] ids = ParseIds(hdnBatchCandIds.Value);
        if (ids.Length == 0) { BindGrid(); return; }
        int updated = ElectionsHelper.BatchUpdateCandidateStatus(ids, "Disqualified", "");
        string qs = ddlElection.SelectedValue != "0" ? "&eid=" + ddlElection.SelectedValue : "";
        RedirectWithFlash(string.Format("{0} candidate(s) disqualified.", updated), true, qs);
    }

    protected void btnBatchCandDelete_Click(object sender, EventArgs e)
    {
        int[] ids = ParseIds(hdnBatchCandIds.Value);
        if (ids.Length == 0) { BindGrid(); return; }
        int removed = ElectionsHelper.BatchDeleteCandidates(ids);
        int skipped = ids.Length - removed;
        string note = skipped > 0 ? string.Format(" ({0} skipped — have votes)", skipped) : "";
        string qs = ddlElection.SelectedValue != "0" ? "&eid=" + ddlElection.SelectedValue : "";
        RedirectWithFlash(string.Format("{0} candidate(s) deleted{1}.", removed, note), true, qs);
    }

    // ─── Flash Helpers ───────────────────────────────────────────────────────
    private void RedirectWithFlash(string msg, bool isOk, string extraQs = "")
    {
        string url = string.Format("ElectionCandidates.aspx?msg={0}&ok={1}{2}",
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
