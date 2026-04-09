using System;
using System.Data;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Masters Certificate Management — graduate student listing with
/// thesis title and supervisor assignment.
///
/// Architecture:
///   Data layer  → GraduateHelper (App_Code/Graduate/GraduateHelper.cs)
///   DB tables   → acad_student, acad_graduate_research, acad_superviors
///   Master page → SidebarMaster.master (ft- design system)
///
/// Features:
///   • Search by name / reg-no / programme
///   • Inline stats cards (total, with thesis, supervisor assigned, in progress)
///   • Modal edit for thesis title + supervisor assignment
///   • Thesis/supervisor data flows into MastersLetterOfAward and FinalTranscript
/// </summary>
public partial class COOPERP_NewScreens_GraduateStudents : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadData();
        }
    }

    // ───────────────────────── Data Loading ───────────────────────────────

    private void LoadData()
    {
        LoadStats();
        LoadStudents(null);
    }

    private void LoadStats()
    {
        try
        {
            var stats = GraduateHelper.GetStats();
            int total = stats.ContainsKey("total") ? stats["total"] : 0;
            int withThesis = stats.ContainsKey("withThesis") ? stats["withThesis"] : 0;
            int withSupervisor = stats.ContainsKey("withSupervisor") ? stats["withSupervisor"] : 0;
            int inProgress = stats.ContainsKey("inProgress") ? stats["inProgress"] : 0;

            litTotal.Text = total.ToString("N0");
            litWithThesis.Text = withThesis.ToString("N0");
            litWithSupervisor.Text = withSupervisor.ToString("N0");
            litInProgress.Text = inProgress.ToString("N0");
            litBadge.Text = String.Format("<span class='ft-card__meta'>{0} students</span>", total);
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading stats: " + ex.Message, false);
        }
    }

    private void LoadStudents(string searchTerm)
    {
        try
        {
            DataTable dt;
            if (string.IsNullOrEmpty(searchTerm))
                dt = GraduateHelper.GetStudentsWithThesis();
            else
                dt = GraduateHelper.SearchStudents(searchTerm);

            rptStudents.DataSource = dt;
            rptStudents.DataBind();
            phNoData.Visible = (dt.Rows.Count == 0);
            litFooter.Text = String.Format("Showing <strong>{0}</strong> graduate student{1}",
                dt.Rows.Count, dt.Rows.Count == 1 ? "" : "s");
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading students: " + ex.Message, false);
        }
    }

    private void LoadSupervisorDropdown()
    {
        try
        {
            ddlSupervisor.Items.Clear();
            ddlSupervisor.Items.Add(new ListItem("-- Select Supervisor --", "0"));

            DataTable supervisors = GraduateHelper.GetSupervisors();
            foreach (DataRow row in supervisors.Rows)
            {
                string name = row["supervior_name"].ToString().Trim();
                string category = row["category"] != DBNull.Value ? row["category"].ToString().Trim() : "";
                string display = string.IsNullOrEmpty(category) ? name : name + " (" + category + ")";
                ddlSupervisor.Items.Add(new ListItem(display, row["Id"].ToString()));
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading supervisors: " + ex.Message, false);
        }
    }

    // ───────────────────────── Search ─────────────────────────────────────

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string search = txtSearch.Text.Trim();
        LoadStats();
        LoadStudents(string.IsNullOrEmpty(search) ? null : search);
    }

    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        LoadData();
    }

    // ───────────────────────── Repeater Commands ─────────────────────────

    protected void rptStudents_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "EditThesis")
        {
            string[] parts = e.CommandArgument.ToString().Split(new string[] { "|||" }, StringSplitOptions.None);
            if (parts.Length >= 4)
            {
                string regno = parts[0];
                string thesisTitle = parts[1];
                string supervisorId = parts[2];
                // parts[3] is res_status (unused in edit form)

                hdnEditRegno.Value = regno;
                txtThesisTitle.Text = thesisTitle;

                // Load supervisor dropdown and select current value
                LoadSupervisorDropdown();

                int sid = 0;
                Int32.TryParse(supervisorId, out sid);
                if (sid > 0 && ddlSupervisor.Items.FindByValue(supervisorId) != null)
                    ddlSupervisor.SelectedValue = supervisorId;
                else
                    ddlSupervisor.SelectedIndex = 0;

                // Set modal title with student info
                litModalTitle.Text = "Edit Thesis &amp; Supervisor";
                litStudentInfo.Text = String.Format(
                    "<div style='font-size:12px;font-weight:600;color:#05275C;padding:6px 10px;background:#f8f9fb;border:1px solid #e0e5ed;'>{0}</div>",
                    HttpUtility.HtmlEncode(regno));

                ShowModal();
            }
        }
    }

    // ───────────────────────── Modal ──────────────────────────────────────

    private void ShowModal()
    {
        pnlModal.Visible = true;
        pnlModal.CssClass = "ft-modal-overlay active";
    }

    private void HideModal()
    {
        pnlModal.Visible = false;
        pnlModal.CssClass = "ft-modal-overlay";
        hdnEditRegno.Value = "";
        txtThesisTitle.Text = "";
    }

    protected void btnCloseModal_Click(object sender, EventArgs e)
    {
        HideModal();
    }

    protected void btnSaveThesis_Click(object sender, EventArgs e)
    {
        string regno = hdnEditRegno.Value.Trim();
        string thesisTitle = txtThesisTitle.Text.Trim();
        int supervisorId = 0;
        Int32.TryParse(ddlSupervisor.SelectedValue, out supervisorId);

        if (string.IsNullOrEmpty(regno))
        {
            ShowMessage("No student selected.", false);
            return;
        }

        try
        {
            GraduateHelper.SaveThesisInfo(regno, thesisTitle, supervisorId);

            HideModal();
            ShowMessage("Thesis info saved for " + regno + ".", true);
            LoadData();
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving thesis info: " + ex.Message, false);
        }
    }

    // ───────────────────────── Display Helpers ────────────────────────────

    /// <summary>Formats first + other name in Title Case.</summary>
    protected string FormatStudentName(object firstName, object otherName)
    {
        string fn = (firstName != null && firstName != DBNull.Value) ? firstName.ToString().Trim() : "";
        string on = (otherName != null && otherName != DBNull.Value) ? otherName.ToString().Trim() : "";
        string full = (fn + " " + on).Trim();
        if (!string.IsNullOrEmpty(full))
            full = new CultureInfo("en").TextInfo.ToTitleCase(full.ToLower());
        return HttpUtility.HtmlEncode(full);
    }

    /// <summary>Truncates text for table display.</summary>
    protected string TruncateText(object val, int maxLen)
    {
        if (val == null || val == DBNull.Value) return "<span style='color:#ccc;font-style:italic;'>Not set</span>";
        string text = val.ToString().Trim();
        if (string.IsNullOrEmpty(text)) return "<span style='color:#ccc;font-style:italic;'>Not set</span>";
        return HttpUtility.HtmlEncode(text.Length > maxLen ? text.Substring(0, maxLen) + "..." : text);
    }

    /// <summary>Formats supervisor name or shows 'Unassigned' badge.</summary>
    protected string FormatSupervisor(object val)
    {
        if (val == null || val == DBNull.Value || string.IsNullOrEmpty(val.ToString().Trim()))
            return "<span class='ft-badge ft-badge--grey'>Unassigned</span>";
        return HttpUtility.HtmlEncode(val.ToString().Trim());
    }

    /// <summary>Formats research status as a colored badge.</summary>
    protected string FormatStatus(object val)
    {
        if (val == null || val == DBNull.Value || string.IsNullOrEmpty(val.ToString().Trim()))
            return "<span class='ft-badge ft-badge--grey'>No Record</span>";

        string status = val.ToString().Trim();
        string lower = status.ToLower();

        if (lower.Contains("complete"))
            return "<span class='ft-badge ft-badge--green'>" + HttpUtility.HtmlEncode(status) + "</span>";
        if (lower.Contains("progress"))
            return "<span class='ft-badge ft-badge--blue'>" + HttpUtility.HtmlEncode(status) + "</span>";
        if (lower.Contains("hold") || lower.Contains("suspend"))
            return "<span class='ft-badge ft-badge--orange'>" + HttpUtility.HtmlEncode(status) + "</span>";

        return "<span class='ft-badge ft-badge--grey'>" + HttpUtility.HtmlEncode(status) + "</span>";
    }

    // ───────────────────────── Messages ───────────────────────────────────

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        string cssClass = isSuccess ? "ft-toast ft-toast--success" : "ft-toast ft-toast--error";
        litMsg.Text = "<div class='" + cssClass + "'>" + HttpUtility.HtmlEncode(msg) + "</div>";
    }
}
