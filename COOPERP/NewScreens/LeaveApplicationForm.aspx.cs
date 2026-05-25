using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_LeaveApplicationForm : System.Web.UI.Page
{
    private static readonly HashSet<string> HrRoles = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        { "hr_manager", "admin" };
    private static readonly HashSet<string> VcRoles = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        { "vc", "admin" };
    private static readonly HashSet<string> HodRoles = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        { "dean", "registrar", "hr_manager", "admin" };

    // ══════════════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ══════════════════════════════════════════════════════════════════════════

    protected void Page_Load(object sender, EventArgs e)
    {
        RoleAccessService.RequireSlug(this, "hr.leave_applications");

        string ajax = (Request.QueryString["ajax"] ?? "").Trim();
        if (!string.IsNullOrEmpty(ajax))
        {
            Response.ContentType = "application/json";
            Response.Cache.SetNoStore();
            HandleAjax(ajax);
            Response.End();
            return;
        }

        if (!IsPostBack)
            LoadForm();
    }

    private void LoadForm()
    {
        string roleCode   = RoleAccessService.GetRoleCode();
        string username   = Session["username"]   as string ?? "";
        string screenName = Session["ScreenName"] as string ?? username;
        bool   isAdmin    = RoleAccessService.IsAdmin();
        bool   isHr       = HrRoles.Contains(roleCode);
        bool   isVc       = VcRoles.Contains(roleCode);
        bool   isHod      = HodRoles.Contains(roleCode);

        int appId = 0;
        int.TryParse(Request.QueryString["id"] ?? "0", out appId);
        bool isPrint = (Request.QueryString["print"] == "1");

        if (appId <= 0)
            RenderNewForm(username, screenName, isAdmin, isHr, isVc, isHod);
        else
            RenderExistingForm(appId, username, screenName, roleCode, isAdmin, isHr, isVc, isHod, isPrint);

        if (isPrint)
            Page.ClientScript.RegisterStartupScript(GetType(), "autoPrint",
                "window.onload = function(){ window.print(); };", true);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  NEW APPLICATION
    // ══════════════════════════════════════════════════════════════════════════

    private void RenderNewForm(string username, string screenName,
        bool isAdmin, bool isHr, bool isVc, bool isHod)
    {
        litPageTitle.Text   = "New Leave Application";
        litStatusBadge.Text = StatusBadge("DRAFT");
        litHeaderSub.Text   = "Complete all sections and submit for HOD/Supervisor approval.";
        litAppId.Text       = "0";
        litPrintBtn.Text    = "";
        litTimeline.Text    = BuildTimeline("DRAFT", "", "", "");

        string supOptions   = LoadSupervisorOptions();
        litSection1.Text    = BuildSection1Editable(null, screenName, supOptions);
        litSection2.Text    = SectionLocked("2", "Section 2 — Head of Department Approval",
                                  "Waiting for employee to submit the application.");
        litSection3.Text    = SectionLocked("3", "Section 3 — Human Resources Department",
                                  "Requires HOD approval before HR can act.");
        litSection4.Text    = SectionLocked("4", "Section 4 — Vice Chancellor's Office",
                                  "Requires HR approval before VC can act.");
        litAuditTrail.Text  = "";

        var ab = new StringBuilder();
        ab.Append("<button type=\"button\" class=\"lf-btn lf-btn--outline\" id=\"btnSaveDraft\" onclick=\"saveDraft(false)\">Save Draft</button>");
        ab.Append("<button type=\"button\" class=\"lf-btn lf-btn--primary\" id=\"btnSubmitApp\" onclick=\"saveDraft(true)\">" +
                  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"12\" height=\"12\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><line x1=\"22\" y1=\"2\" x2=\"11\" y2=\"13\"/><polygon points=\"22 2 15 22 11 13 2 9 22 2\"/></svg>" +
                  " Submit Application</button>");
        ab.Append("<span class=\"lf-actions__note\">Application will be forwarded to the selected supervisor for HOD approval.</span>");
        litActionBar.Text = ab.ToString();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  EXISTING APPLICATION
    // ══════════════════════════════════════════════════════════════════════════

    private void RenderExistingForm(int appId, string username, string screenName,
        string roleCode, bool isAdmin, bool isHr, bool isVc, bool isHod, bool isPrint)
    {
        Dictionary<string, object> app = LoadApp(appId);

        if (app == null)
        {
            litSection1.Text = "<div style=\"color:#dc2626;padding:20px;\">Application not found or has been cancelled.</div>";
            litActionBar.Text = "";
            return;
        }

        string status    = S(app, "status");
        string empName   = S(app, "emp_name");
        string createdBy = S(app, "created_by");
        string supUser   = S(app, "supervisor_username");

        // Access check: employees see only their own
        if (!isAdmin && !isHr && !isVc && !isHod &&
            !string.Equals(createdBy, username, StringComparison.OrdinalIgnoreCase))
        {
            litSection1.Text  = "<div style=\"color:#dc2626;padding:20px;\">You do not have permission to view this application.</div>";
            litActionBar.Text = "";
            return;
        }

        litPageTitle.Text   = "Leave Application — " + HttpUtility.HtmlEncode(empName);
        litStatusBadge.Text = StatusBadge(status);
        litHeaderSub.Text   = "Application #" + appId + " &nbsp;·&nbsp; " +
                              HttpUtility.HtmlEncode(LeaveTypeLabel(S(app, "leave_type"))) +
                              " &nbsp;·&nbsp; " + FormatDate(app, "leave_from") +
                              " to " + FormatDate(app, "leave_to");
        litAppId.Text       = appId.ToString();
        litPrintBtn.Text    =
            "<button type=\"button\" class=\"lf-btn lf-btn--outline\" onclick=\"printForm()\">" +
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"6 9 6 2 18 2 18 9\"/><path d=\"M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2\"/><rect x=\"6\" y=\"14\" width=\"12\" height=\"8\"/></svg>" +
            " Print</button>";

        litTimeline.Text = BuildTimeline(status, S(app, "hod_actor_name"), S(app, "hr_actor_name"), S(app, "vc_decision"));

        // ── Section 1 ──────────────────────────────────────────────────────────
        bool canEditDraft = (status == "DRAFT") &&
            (isAdmin || string.Equals(createdBy, username, StringComparison.OrdinalIgnoreCase));
        litSection1.Text = canEditDraft
            ? BuildSection1Editable(app, screenName, LoadSupervisorOptions())
            : BuildSection1Readonly(app);

        // ── Section 2 ──────────────────────────────────────────────────────────
        bool isAssignedHod = string.Equals(supUser, username, StringComparison.OrdinalIgnoreCase);
        bool canActHod = (status == "SUBMITTED") && (isAdmin || isHod || isAssignedHod);

        if (status == "DRAFT")
            litSection2.Text = SectionLocked("2", "Section 2 — Head of Department Approval",
                "Waiting for employee to submit the application.");
        else if (status == "SUBMITTED" && canActHod)
            litSection2.Text = BuildSection2Active(app);
        else if (status == "SUBMITTED")
            litSection2.Text = SectionLocked("2", "Section 2 — Head of Department Approval",
                "Application submitted — awaiting HOD / Supervisor action.");
        else
            litSection2.Text = BuildSection2Readonly(app);

        // ── Section 3 ──────────────────────────────────────────────────────────
        bool canActHr = (status == "HOD_APPROVED") && (isAdmin || isHr);

        if (status == "DRAFT" || status == "SUBMITTED" || status == "HOD_DECLINED")
            litSection3.Text = SectionLocked("3", "Section 3 — Human Resources Department",
                status == "HOD_DECLINED" ? "HOD declined — HR review not required." : "Requires HOD approval before HR can act.");
        else if (canActHr)
            litSection3.Text = BuildSection3Active(app);
        else if (status == "HOD_APPROVED")
            litSection3.Text = SectionLocked("3", "Section 3 — Human Resources Department",
                "HOD approved — awaiting HR Department action.");
        else
            litSection3.Text = BuildSection3Readonly(app);

        // ── Section 4 ──────────────────────────────────────────────────────────
        bool canActVc = (status == "HR_APPROVED") && (isAdmin || isVc);
        bool vcDone   = (status == "VC_GRANTED" || status == "VC_NOT_GRANTED" || status == "VC_POSTPONED");

        if (status == "DRAFT" || status == "SUBMITTED" || status == "HOD_DECLINED" ||
            status == "HOD_APPROVED" || status == "HR_DECLINED")
            litSection4.Text = SectionLocked("4", "Section 4 — Vice Chancellor's Office",
                "Requires HR approval before VC can act.");
        else if (canActVc)
            litSection4.Text = BuildSection4Active(app);
        else if (status == "HR_APPROVED")
            litSection4.Text = SectionLocked("4", "Section 4 — Vice Chancellor's Office",
                "HR approved — awaiting Vice Chancellor's decision.");
        else if (vcDone)
            litSection4.Text = BuildSection4Readonly(app);
        else
            litSection4.Text = SectionLocked("4", "Section 4 — Vice Chancellor's Office", "");

        litAuditTrail.Text = BuildAuditTrail(appId);
        litActionBar.Text  = BuildActionBar(app, appId, status, username,
            isAdmin, isHr, isVc, isHod, canEditDraft, canActHod, canActHr, canActVc);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  TIMELINE
    // ══════════════════════════════════════════════════════════════════════════

    private static string BuildTimeline(string status, string hodActor, string hrActor, string vcDecision)
    {
        // Step states
        bool isNew         = (status == "DRAFT");
        bool hodDeclined   = (status == "HOD_DECLINED");
        bool hrDeclined    = (status == "HR_DECLINED");
        bool vcNotGood     = (status == "VC_NOT_GRANTED" || status == "VC_POSTPONED");
        bool vcGranted     = (status == "VC_GRANTED");

        bool submitted     = !isNew;
        bool hodActed      = submitted && status != "SUBMITTED";
        bool hodOk         = hodActed && !hodDeclined;
        bool hrActed       = hodOk && status != "HOD_APPROVED";
        bool hrOk          = hrActed && !hrDeclined;
        bool vcActed       = hrOk && status != "HR_APPROVED";

        string step1Cls = isNew      ? "active" : "done";
        string step1Sub = isNew      ? "Filling form" : "Submitted";

        string step2Cls = !submitted ? "" : (hodDeclined ? "declined" : (hodActed ? "done" : "active"));
        string step2Sub = !submitted ? "Awaiting submission"
                        : hodDeclined ? "Declined by HOD"
                        : hodActed   ? "Approved" + (string.IsNullOrEmpty(hodActor) ? "" : " by " + hodActor)
                        : "Awaiting HOD action";

        string step3Cls = !hodOk ? "" : (hrDeclined ? "declined" : (hrActed ? "done" : "active"));
        string step3Sub = !hodOk ? "Pending HOD approval"
                        : hrDeclined ? "Declined by HR"
                        : hrActed   ? "Approved" + (string.IsNullOrEmpty(hrActor) ? "" : " by " + hrActor)
                        : "Awaiting HR Department";

        string step4Cls = !hrOk ? "" : (vcNotGood ? "declined" : (vcActed ? "done" : "active"));
        string step4Sub = !hrOk ? "Pending HR approval"
                        : vcGranted ? "Leave Granted"
                        : vcNotGood ? (status == "VC_POSTPONED" ? "Postponed" : "Not Granted")
                        : vcActed   ? "Decision issued"
                        : "Awaiting VC decision";

        var sb = new StringBuilder();
        sb.Append("<div class=\"lf-timeline\">");
        sb.Append(TlStep("1", "Employee", step1Sub, step1Cls));
        sb.Append(TlArrow(step1Cls == "done"));
        sb.Append(TlStep("2", "HOD Approval", step2Sub, step2Cls));
        sb.Append(TlArrow(step2Cls == "done"));
        sb.Append(TlStep("3", "HR Department", step3Sub, step3Cls));
        sb.Append(TlArrow(step3Cls == "done"));
        sb.Append(TlStep("4", "Vice Chancellor", step4Sub, step4Cls));
        sb.Append("</div>");
        return sb.ToString();
    }

    private static string TlStep(string num, string label, string sub, string cls)
    {
        string dotCls = cls == "done" ? "lf-step__dot--done"
                      : cls == "active" ? "lf-step__dot--active"
                      : cls == "declined" ? "lf-step__dot--declined" : "";
        string icon   = cls == "done" ? "&#10003;" : cls == "declined" ? "&#10007;" : num;
        return string.Format(
            "<div class=\"lf-step\">" +
            "<div class=\"lf-step__dot {0}\">{1}</div>" +
            "<div class=\"lf-step__info\">" +
            "<div class=\"lf-step__label\">{2}</div>" +
            "<div class=\"lf-step__sub\">{3}</div>" +
            "</div></div>",
            dotCls, icon,
            HttpUtility.HtmlEncode(label),
            HttpUtility.HtmlEncode(sub));
    }
    private static string TlArrow(bool done)
    {
        return "<div class=\"lf-step__arrow" + (done ? " lf-step__arrow--done" : "") + "\"></div>";
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  SECTION 1 — EMPLOYEE DETAILS
    // ══════════════════════════════════════════════════════════════════════════

    private string BuildSection1Editable(Dictionary<string, object> app, string screenName, string supOptions)
    {
        string empName  = app != null ? S(app, "emp_name")   : screenName;
        string empCode  = app != null ? S(app, "emp_code")   : "";
        string dept     = app != null ? S(app, "faculty_dept") : "";
        string office   = app != null ? S(app, "office_location") : "";
        string position = app != null ? S(app, "position_held")   : "";
        string address  = app != null ? S(app, "residence_address") : "";
        string mobile   = app != null ? S(app, "mobile_contact")  : "";
        string nokName  = app != null ? S(app, "nok_name")   : "";
        string nokAddr  = app != null ? S(app, "nok_address") : "";
        string nokMob   = app != null ? S(app, "nok_mobile")  : "";
        string lvType   = app != null ? S(app, "leave_type")  : "annual";
        string lvFrom   = app != null ? DateVal(app, "leave_from") : "";
        string lvTo     = app != null ? DateVal(app, "leave_to")   : "";
        int    numDays  = app != null ? N(app, "num_days")    : 0;
        string subst    = app != null ? S(app, "substitute_arrangement") : "";
        string supUname = app != null ? S(app, "supervisor_username") : "";
        string supDispName = app != null ? S(app, "supervisor_name") : "";

        var sb = new StringBuilder();
        sb.Append("<div class=\"lf-section lf-section--active\">");
        sb.Append("<div class=\"lf-section__head\">");
        sb.Append("<div class=\"lf-section__num\">1</div>");
        sb.Append("<div class=\"lf-section__title\">Section 1 — Employee Details &amp; Leave Request</div>");
        sb.Append("<span class=\"lf-section__badge badge--waiting\">Filling</span>");
        sb.Append("</div><div class=\"lf-section__body\">");

        sb.Append("<div class=\"lf-grid lf-grid--3\" style=\"margin-bottom:14px;\">");
        sb.Append(LfField("Employee Name *", "empName", "text", empName, "Full name as per records"));
        sb.Append(LfField("Employee Code", "empCode", "text", empCode, "e.g. MRU-001"));
        sb.Append(LfField("Faculty / Department / Section", "empDept", "text", dept, ""));
        sb.Append("</div>");

        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(LfField("Office Location", "officeLocation", "text", office, "Building / Office"));
        sb.Append(LfField("Position Held", "positionHeld", "text", position, "e.g. Senior Lecturer"));
        sb.Append("</div>");

        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(LfTextarea("Residence Address During Leave", "residenceAddress", address, "Home address where you can be reached"));
        sb.Append(LfField("Mobile Contact", "mobileContact", "tel", mobile, "+256 ..."));
        sb.Append("</div>");

        sb.Append("<div class=\"lf-grid lf-grid--3\" style=\"margin-bottom:14px;\">");
        sb.Append(LfField("Next of Kin / Spouse / Parent Name", "nokName", "text", nokName, "Emergency contact name"));
        sb.Append(LfTextarea("NOK Address", "nokAddress", nokAddr, ""));
        sb.Append(LfField("NOK Mobile", "nokMobile", "tel", nokMob, "+256 ..."));
        sb.Append("</div>");

        // Leave type radio grid
        sb.Append("<div style=\"margin-bottom:14px;\">");
        sb.Append("<label style=\"display:block;font-size:10px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:6px;\">Leave Type *</label>");
        sb.Append("<div class=\"leave-type-grid\">");
        sb.Append(LvTypeRadio("annual",      "Annual Leave",       lvType));
        sb.Append(LvTypeRadio("study",       "Study Leave",        lvType));
        sb.Append(LvTypeRadio("sick",        "Sick Leave",         lvType));
        sb.Append(LvTypeRadio("maternity",   "Maternity Leave",    lvType));
        sb.Append(LvTypeRadio("bereavement", "Family Bereavement", lvType));
        sb.Append("</div>");
        sb.AppendFormat("<input type=\"hidden\" id=\"leaveType\" value=\"{0}\" />", HttpUtility.HtmlAttributeEncode(lvType));
        sb.Append("</div>");

        // Dates + Days
        sb.Append("<div class=\"lf-grid lf-grid--3\" style=\"margin-bottom:14px;\">");
        sb.AppendFormat("<div class=\"lf-field\"><label>Leave From *</label><input type=\"date\" id=\"leaveFrom\" value=\"{0}\" onchange=\"autoCalcDays()\" /></div>", HttpUtility.HtmlAttributeEncode(lvFrom));
        sb.AppendFormat("<div class=\"lf-field\"><label>Leave To *</label><input type=\"date\" id=\"leaveTo\" value=\"{0}\" onchange=\"autoCalcDays()\" /></div>", HttpUtility.HtmlAttributeEncode(lvTo));
        sb.AppendFormat("<div class=\"lf-field\"><label>Number of Days</label><input type=\"number\" id=\"numDays\" value=\"{0}\" readonly style=\"background:var(--surf);\" /></div>", numDays > 0 ? numDays.ToString() : "");
        sb.Append("</div>");

        // Substitute
        sb.Append("<div style=\"margin-bottom:14px;\">");
        sb.Append(LfTextarea("Substitute / Coverage Arrangement", "substituteArrangement", subst, "Who will cover your duties and how…"));
        sb.Append("</div>");

        // Supervisor dropdown
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:4px;\">");
        sb.Append("<div class=\"lf-field\"><label>Supervisor / Head of Department *</label>");
        sb.Append("<select id=\"supUsername\"><option value=\"\">— Select Supervisor / HOD —</option>");
        sb.Append(supOptions);
        sb.Append("</select></div></div>");

        sb.Append("</div></div>"); // body + section

        // JS: sync radio → hidden field + pre-select supervisor
        sb.Append("<script>");
        sb.Append("document.querySelectorAll('[name=leaveTypeRadio]').forEach(function(r){r.addEventListener('change',function(){document.getElementById('leaveType').value=this.value;});});");
        if (!string.IsNullOrEmpty(supUname))
        {
            string safeU = supUname.Replace("\\", "\\\\").Replace("'", "\\'");
            string safeN = (string.IsNullOrEmpty(supDispName) ? supUname : supDispName).Replace("\\", "\\\\").Replace("'", "\\'");
            sb.AppendFormat(
                "(function(){{var s=document.getElementById('supUsername'),found=false;" +
                "for(var i=0;i<s.options.length;i++)if(s.options[i].value==='{0}'){{s.selectedIndex=i;found=true;break;}}" +
                "if(!found&&'{0}'){{var o=document.createElement('option');o.value='{0}';o.text='{1}';o.selected=true;s.add(o);}}" +
                "}})();",
                safeU, safeN);
        }
        sb.Append("</script>");

        return sb.ToString();
    }

    private static string LvTypeRadio(string value, string label, string selected)
    {
        bool chk = string.Equals(value, selected, StringComparison.OrdinalIgnoreCase);
        return string.Format(
            "<div class=\"leave-type-opt\">" +
            "<input type=\"radio\" name=\"leaveTypeRadio\" id=\"lt_{0}\" value=\"{0}\"{1} />" +
            "<label for=\"lt_{0}\">{2}</label></div>",
            value, chk ? " checked" : "", HttpUtility.HtmlEncode(label));
    }

    private static string BuildSection1Readonly(Dictionary<string, object> app)
    {
        string status = S(app, "status");
        string cls    = (status == "CANCELLED") ? "" : "lf-section--completed";
        string badge  = (status == "CANCELLED")
            ? "<span class=\"lf-section__badge badge--locked\">Cancelled</span>"
            : "<span class=\"lf-section__badge badge--approved\">Submitted</span>";

        var sb = new StringBuilder();
        sb.AppendFormat("<div class=\"lf-section {0}\">", cls);
        sb.Append("<div class=\"lf-section__head\">");
        sb.Append("<div class=\"lf-section__num\">&#10003;</div>");
        sb.Append("<div class=\"lf-section__title\">Section 1 — Employee Details &amp; Leave Request</div>");
        sb.Append(badge);
        sb.Append("</div><div class=\"lf-section__body\">");

        sb.Append("<div class=\"lf-grid lf-grid--3\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("Employee Name",                 S(app, "emp_name")));
        sb.Append(RoField("Employee Code",                 S(app, "emp_code")));
        sb.Append(RoField("Faculty / Department / Section",S(app, "faculty_dept")));
        sb.Append("</div>");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("Office Location", S(app, "office_location")));
        sb.Append(RoField("Position Held",   S(app, "position_held")));
        sb.Append("</div>");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("Residence Address", S(app, "residence_address")));
        sb.Append(RoField("Mobile Contact",    S(app, "mobile_contact")));
        sb.Append("</div>");
        sb.Append("<div class=\"lf-grid lf-grid--3\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("Next of Kin Name", S(app, "nok_name")));
        sb.Append(RoField("NOK Address",      S(app, "nok_address")));
        sb.Append(RoField("NOK Mobile",       S(app, "nok_mobile")));
        sb.Append("</div>");
        sb.Append("<div class=\"lf-grid lf-grid--3\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("Leave Type",     LeaveTypeLabel(S(app, "leave_type"))));
        sb.Append(RoField("From",           FormatDate(app, "leave_from")));
        sb.Append(RoField("To",             FormatDate(app, "leave_to")));
        sb.Append("</div>");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        int nd = N(app, "num_days");
        sb.Append(RoField("Number of Days",           nd > 0 ? nd + " days" : "—"));
        sb.Append(RoField("Substitute Arrangement",   S(app, "substitute_arrangement")));
        sb.Append("</div>");
        string supDisp = S(app, "supervisor_name");
        string supUser = S(app, "supervisor_username");
        string supFull = string.IsNullOrEmpty(supDisp) ? supUser : supDisp + (!string.IsNullOrEmpty(supUser) ? " (" + supUser + ")" : "");
        sb.Append(RoField("Supervisor / HOD", supFull));

        string submitted = FormatDateTime(app, "employee_submitted_at");
        if (!string.IsNullOrEmpty(submitted))
            sb.AppendFormat("<p style=\"font-size:10px;color:var(--muted);margin:12px 0 0;\">Submitted on {0}</p>",
                HttpUtility.HtmlEncode(submitted));

        sb.Append("</div></div>");
        return sb.ToString();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  SECTION 2 — HOD
    // ══════════════════════════════════════════════════════════════════════════

    private static string BuildSection2Active(Dictionary<string, object> app)
    {
        var sb = new StringBuilder();
        sb.Append("<div class=\"lf-section lf-section--active\">");
        sb.Append("<div class=\"lf-section__head\">");
        sb.Append("<div class=\"lf-section__num\">2</div>");
        sb.Append("<div class=\"lf-section__title\">Section 2 — Head of Department Approval</div>");
        sb.Append("<span class=\"lf-section__badge badge--waiting\">Awaiting Your Action</span>");
        sb.Append("</div><div class=\"lf-section__body\">");
        sb.Append("<p style=\"font-size:12px;color:#374151;margin:0 0 8px;\">Review the employee details above. Approve and forward to HR, or decline.</p>");
        sb.Append("<p style=\"font-size:11px;color:var(--muted);margin:0;\">Use the action buttons in the bar below to approve or decline this application.</p>");
        sb.Append("</div></div>");
        return sb.ToString();
    }

    private static string BuildSection2Readonly(Dictionary<string, object> app)
    {
        bool approved = S(app, "hod_action") == "APPROVED";
        string cls   = approved ? "lf-section--completed" : "lf-section--declined";
        string badge = approved
            ? "<span class=\"lf-section__badge badge--approved\">Approved</span>"
            : "<span class=\"lf-section__badge badge--declined\">Declined</span>";
        string dot   = approved ? "&#10003;" : "&#10007;";

        var sb = new StringBuilder();
        sb.AppendFormat("<div class=\"lf-section {0}\">", cls);
        sb.Append("<div class=\"lf-section__head\">");
        sb.AppendFormat("<div class=\"lf-section__num\">{0}</div>", dot);
        sb.Append("<div class=\"lf-section__title\">Section 2 — Head of Department Approval</div>");
        sb.Append(badge);
        sb.Append("</div><div class=\"lf-section__body\">");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("HOD Decision",  approved ? "Approved" : "Declined"));
        sb.Append(RoField("Actioned By",   S(app, "hod_actor_name")));
        sb.Append("</div>");
        if (approved)
        {
            sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
            sb.Append(RoField("Handover To", S(app, "hod_handover_to")));
            sb.Append(RoField("Date",        FormatDate(app, "hod_action_at")));
            sb.Append("</div>");
        }
        else
        {
            sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
            sb.Append(RoField("Date",   FormatDate(app, "hod_action_at")));
            sb.Append(RoField("Reason", S(app, "hod_notes")));
            sb.Append("</div>");
        }
        string notes = S(app, "hod_notes");
        if (approved && !string.IsNullOrEmpty(notes))
            sb.Append(RoField("Notes / Remarks", notes));
        sb.Append("</div></div>");
        return sb.ToString();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  SECTION 3 — HR
    // ══════════════════════════════════════════════════════════════════════════

    private static string BuildSection3Active(Dictionary<string, object> app)
    {
        var sb = new StringBuilder();
        sb.Append("<div class=\"lf-section lf-section--active\">");
        sb.Append("<div class=\"lf-section__head\">");
        sb.Append("<div class=\"lf-section__num\">3</div>");
        sb.Append("<div class=\"lf-section__title\">Section 3 — Human Resources Department</div>");
        sb.Append("<span class=\"lf-section__badge badge--waiting\">Awaiting HR Action</span>");
        sb.Append("</div><div class=\"lf-section__body\">");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("HOD Handover To",  S(app, "hod_handover_to")));
        sb.Append(RoField("HOD Approved By",  S(app, "hod_actor_name")));
        sb.Append("</div>");
        sb.Append("<p style=\"font-size:11px;color:var(--muted);margin:0;\">Use the Approve or Decline buttons in the action bar to process this application.</p>");
        sb.Append("</div></div>");
        return sb.ToString();
    }

    private static string BuildSection3Readonly(Dictionary<string, object> app)
    {
        bool approved = S(app, "hr_action") == "APPROVED";
        string cls   = approved ? "lf-section--completed" : "lf-section--declined";
        string badge = approved
            ? "<span class=\"lf-section__badge badge--approved\">Approved</span>"
            : "<span class=\"lf-section__badge badge--declined\">Declined</span>";

        var sb = new StringBuilder();
        sb.AppendFormat("<div class=\"lf-section {0}\">", cls);
        sb.Append("<div class=\"lf-section__head\">");
        sb.AppendFormat("<div class=\"lf-section__num\">{0}</div>", approved ? "&#10003;" : "&#10007;");
        sb.Append("<div class=\"lf-section__title\">Section 3 — Human Resources Department</div>");
        sb.Append(badge);
        sb.Append("</div><div class=\"lf-section__body\">");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("HR Decision",   approved ? "Approved" : "Declined"));
        sb.Append(RoField("Actioned By",   S(app, "hr_actor_name")));
        sb.Append("</div>");
        if (approved)
        {
            sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
            sb.Append(RoField("Effective From", FormatDate(app, "hr_effective_from")));
            sb.Append(RoField("Effective To",   FormatDate(app, "hr_effective_to")));
            sb.Append("</div>");
        }
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("Date Actioned", FormatDate(app, "hr_action_at")));
        string hrNotes = S(app, "hr_notes");
        if (!string.IsNullOrEmpty(hrNotes)) sb.Append(RoField("HR Notes", hrNotes));
        sb.Append("</div>");
        sb.Append("</div></div>");
        return sb.ToString();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  SECTION 4 — VC
    // ══════════════════════════════════════════════════════════════════════════

    private static string BuildSection4Active(Dictionary<string, object> app)
    {
        var sb = new StringBuilder();
        sb.Append("<div class=\"lf-section lf-section--active\">");
        sb.Append("<div class=\"lf-section__head\">");
        sb.Append("<div class=\"lf-section__num\">4</div>");
        sb.Append("<div class=\"lf-section__title\">Section 4 — Vice Chancellor's Office</div>");
        sb.Append("<span class=\"lf-section__badge badge--waiting\">Awaiting VC Decision</span>");
        sb.Append("</div><div class=\"lf-section__body\">");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("HR Effective From", FormatDate(app, "hr_effective_from")));
        sb.Append(RoField("HR Effective To",   FormatDate(app, "hr_effective_to")));
        sb.Append("</div>");
        sb.Append("<p style=\"font-size:11px;color:var(--muted);margin:0;\">Use the Grant, Not Grant, or Postpone buttons in the action bar to issue a decision.</p>");
        sb.Append("</div></div>");
        return sb.ToString();
    }

    private static string BuildSection4Readonly(Dictionary<string, object> app)
    {
        string vcDec  = S(app, "vc_decision");
        bool granted  = (vcDec == "GRANTED");
        bool postponed = (vcDec == "POSTPONED");
        string cls    = granted ? "lf-section--completed" : "lf-section--declined";
        string badgeLbl = granted ? "Granted" : (postponed ? "Postponed" : "Not Granted");
        string badgeCls = granted ? "badge--granted" : (postponed ? "badge--postponed" : "badge--notgranted");

        var sb = new StringBuilder();
        sb.AppendFormat("<div class=\"lf-section {0}\">", cls);
        sb.Append("<div class=\"lf-section__head\">");
        sb.AppendFormat("<div class=\"lf-section__num\">{0}</div>", granted ? "&#10003;" : "&#10007;");
        sb.Append("<div class=\"lf-section__title\">Section 4 — Vice Chancellor's Office</div>");
        sb.AppendFormat("<span class=\"lf-section__badge {0}\">{1}</span>", badgeCls, badgeLbl);
        sb.Append("</div><div class=\"lf-section__body\">");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        sb.Append(RoField("VC Decision",  badgeLbl));
        sb.Append(RoField("Actioned By",  S(app, "vc_actor_name")));
        sb.Append("</div>");
        sb.Append("<div class=\"lf-grid\" style=\"margin-bottom:14px;\">");
        int accum = N(app, "vc_accumulated_days");
        int taken = N(app, "vc_days_taken");
        sb.Append(RoField("Accumulated Leave Days",    accum > 0 ? accum.ToString() : "—"));
        sb.Append(RoField("Days Granted (This Leave)", taken > 0 ? taken.ToString() : "—"));
        sb.Append("</div>");
        string vcReason = S(app, "vc_reason");
        if (!string.IsNullOrEmpty(vcReason)) sb.Append(RoField("Remarks", vcReason));
        sb.Append(RoField("Date", FormatDate(app, "vc_action_at")));
        sb.Append("</div></div>");
        return sb.ToString();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  ACTION BAR
    // ══════════════════════════════════════════════════════════════════════════

    private static string BuildActionBar(Dictionary<string, object> app, int appId, string status,
        string username, bool isAdmin, bool isHr, bool isVc, bool isHod,
        bool canEditDraft, bool canActHod, bool canActHr, bool canActVc)
    {
        var sb = new StringBuilder();

        if (canEditDraft)
        {
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--outline\" id=\"btnSaveDraft\" onclick=\"saveDraft(false)\">Save Draft</button>");
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--primary\" id=\"btnSubmitApp\" onclick=\"saveDraft(true)\">Submit Application</button>");
        }
        if (canActHod)
        {
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--success\" onclick=\"openModal('modalHodApprove')\">Approve &amp; Forward to HR</button>");
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--danger\" onclick=\"openModal('modalHodDecline')\">Decline</button>");
        }
        if (canActHr)
        {
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--success\" onclick=\"openModal('modalHrApprove')\">Approve &amp; Forward to VC</button>");
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--danger\" onclick=\"openModal('modalHrDecline')\">Decline</button>");
        }
        if (canActVc)
        {
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--success\" onclick=\"openModal('modalVcGrant')\">Grant Leave</button>");
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--warn\" onclick=\"openVcOther('NOT_GRANTED')\">Not Grant</button>");
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--outline\" onclick=\"openVcOther('POSTPONED')\">Postpone</button>");
        }

        // Cancel for admin/HR
        if ((isAdmin || isHr) && status != "CANCELLED" && status != "VC_GRANTED")
        {
            if (sb.Length > 0) sb.Append("<span style=\"flex:1\"></span>");
            sb.Append("<button type=\"button\" class=\"lf-btn lf-btn--danger\" onclick=\"cancelAppForm()\">" +
                "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><line x1=\"15\" y1=\"9\" x2=\"9\" y2=\"15\"/><line x1=\"9\" y1=\"9\" x2=\"15\" y2=\"15\"/></svg>" +
                " Cancel Application</button>");
        }

        if (!canEditDraft && !canActHod && !canActHr && !canActVc)
        {
            sb.AppendFormat("<span class=\"lf-actions__note\" style=\"color:var(--txt);font-weight:600;\">{0}</span>",
                HttpUtility.HtmlEncode(StatusNote(status)));
        }

        // cancelAppForm JS (uses APP_ID from the page)
        sb.Append("<script>function cancelAppForm(){" +
            "if(!confirm('Cancel this leave application? This cannot be undone.'))return;" +
            "fetch('LeaveApplicationForm.aspx?ajax=cancel',{method:'POST'," +
            "headers:{'Content-Type':'application/x-www-form-urlencoded'}," +
            "body:'id='+encodeURIComponent(APP_ID)})" +
            ".then(function(r){return r.json();})" +
            ".then(function(d){if(d.ok){showToast('Application cancelled.','ok');" +
            "setTimeout(function(){location.href='LeaveApplications.aspx';},1300);}else showToast(d.error||'Failed.','err');});" +
            "}</script>");

        return sb.ToString();
    }

    private static string StatusNote(string status)
    {
        switch (status)
        {
            case "SUBMITTED":      return "Application submitted — awaiting HOD approval.";
            case "HOD_APPROVED":   return "HOD approved — awaiting HR Department review.";
            case "HOD_DECLINED":   return "Application was declined by the Head of Department.";
            case "HR_APPROVED":    return "HR approved — awaiting Vice Chancellor's decision.";
            case "HR_DECLINED":    return "Application was declined by the HR Department.";
            case "VC_GRANTED":     return "Leave granted by the Vice Chancellor.";
            case "VC_NOT_GRANTED": return "Leave was not granted by the Vice Chancellor.";
            case "VC_POSTPONED":   return "Leave has been postponed by the Vice Chancellor.";
            case "CANCELLED":      return "This application has been cancelled.";
            default:               return "Application is in " + status + " status.";
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  AUDIT TRAIL
    // ══════════════════════════════════════════════════════════════════════════

    private string BuildAuditTrail(int appId)
    {
        var sb = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                const string sql = @"
                    SELECT action_code, old_status, new_status,
                           actor_name, actor_role, remarks, created_at
                    FROM hrm_leave_audit WHERE application_id=@id ORDER BY created_at ASC";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", appId);
                    using (var dr = cmd.ExecuteReader())
                    {
                        bool any = false;
                        while (dr.Read())
                        {
                            if (!any)
                            {
                                sb.Append("<div class=\"lf-audit__title\">Audit Trail</div>");
                                any = true;
                            }
                            string code    = dr["action_code"].ToString();
                            string actor   = dr["actor_name"].ToString();
                            string role    = dr["actor_role"].ToString();
                            string remarks = dr["remarks"] == DBNull.Value ? "" : dr["remarks"].ToString();
                            DateTime when  = Convert.ToDateTime(dr["created_at"]);

                            string dotCls = "audit-dot";
                            if (code.Contains("APPROVED") || code == "VC_GRANTED") dotCls += " audit-dot--ok";
                            else if (code.Contains("DECLINED") || code == "VC_NOT_GRANTED" || code == "CANCELLED") dotCls += " audit-dot--err";
                            else if (code == "SUBMITTED") dotCls += " audit-dot--warn";

                            sb.Append("<div class=\"audit-entry\">");
                            sb.AppendFormat("<div class=\"{0}\"></div>", dotCls);
                            sb.Append("<div class=\"audit-body\">");
                            sb.AppendFormat("<div class=\"audit-action\">{0}</div>",
                                HttpUtility.HtmlEncode(AuditLabel(code)));
                            sb.AppendFormat("<div class=\"audit-meta\">{0} — {1} &nbsp;·&nbsp; {2}</div>",
                                HttpUtility.HtmlEncode(actor),
                                HttpUtility.HtmlEncode(role),
                                HttpUtility.HtmlEncode(when.ToString("dd MMM yyyy, h:mm tt")));
                            if (!string.IsNullOrEmpty(remarks))
                                sb.AppendFormat("<div class=\"audit-remark\">&ldquo;{0}&rdquo;</div>",
                                    HttpUtility.HtmlEncode(remarks));
                            sb.Append("</div></div>");
                        }
                    }
                }
            }
        }
        catch { /* don't break page on audit errors */ }
        return sb.ToString();
    }

    private static string AuditLabel(string code)
    {
        switch (code)
        {
            case "DRAFT_SAVED":    return "Draft saved";
            case "SUBMITTED":      return "Application submitted";
            case "HOD_APPROVED":   return "Approved by Head of Department";
            case "HOD_DECLINED":   return "Declined by Head of Department";
            case "HR_APPROVED":    return "Approved by HR Department";
            case "HR_DECLINED":    return "Declined by HR Department";
            case "VC_GRANTED":     return "Leave Granted by Vice Chancellor";
            case "VC_NOT_GRANTED": return "Not Granted by Vice Chancellor";
            case "VC_POSTPONED":   return "Postponed by Vice Chancellor";
            case "CANCELLED":      return "Application Cancelled";
            default:               return code;
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  AJAX ROUTER
    // ══════════════════════════════════════════════════════════════════════════

    private void HandleAjax(string action)
    {
        string username   = Session["username"]   as string ?? "";
        string screenName = Session["ScreenName"] as string ?? username;
        string roleCode   = RoleAccessService.GetRoleCode();
        string ip         = Request.UserHostAddress;
        bool   isAdmin    = RoleAccessService.IsAdmin();
        bool   isHr       = HrRoles.Contains(roleCode);
        bool   isVc       = VcRoles.Contains(roleCode);
        bool   isHod      = HodRoles.Contains(roleCode);

        try
        {
            switch (action)
            {
                case "save_draft":  AjaxSaveDraft(username, screenName, ip, false, isAdmin); break;
                case "submit":      AjaxSaveDraft(username, screenName, ip, true,  isAdmin); break;
                case "hod_approve": AjaxHodApprove(username, screenName, ip, isAdmin, isHod); break;
                case "hod_decline": AjaxHodDecline(username, screenName, ip, isAdmin, isHod); break;
                case "hr_approve":  AjaxHrApprove(username, screenName, ip, isAdmin, isHr);  break;
                case "hr_decline":  AjaxHrDecline(username, screenName, ip, isAdmin, isHr);  break;
                case "vc_decision": AjaxVcDecision(username, screenName, roleCode, ip, isAdmin, isVc); break;
                case "cancel":      AjaxCancel(username, screenName, roleCode, ip, isAdmin, isHr); break;
                default: Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}"); break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":" + JsonStr(ex.Message) + "}");
        }
    }

    // ── Save Draft / Submit ────────────────────────────────────────────────────

    private void AjaxSaveDraft(string username, string screenName, string ip, bool submit, bool isAdmin)
    {
        int    appId    = FormInt("id");
        string empName  = FormStr("emp_name");
        string lvType   = FormStr("leave_type");
        string lvFrom   = FormStr("leave_from");
        string lvTo     = FormStr("leave_to");

        if (string.IsNullOrEmpty(empName))
        { Err("Employee name is required."); return; }
        if (string.IsNullOrEmpty(lvType))
        { Err("Leave type is required."); return; }

        DateTime dtFrom, dtTo;
        if (!DateTime.TryParse(lvFrom, out dtFrom) || !DateTime.TryParse(lvTo, out dtTo))
        { Err("Invalid leave dates."); return; }
        if (dtTo < dtFrom)
        { Err("End date must be after start date."); return; }

        int numDays = FormInt("num_days");
        if (numDays <= 0) numDays = (int)Math.Round((dtTo - dtFrom).TotalDays) + 1;

        string supUser = FormStr("supervisor_username");
        string supName = FormStr("supervisor_name");
        if (submit && string.IsNullOrEmpty(supUser))
        { Err("Please select a Supervisor / HOD."); return; }

        string newStatus = submit ? "SUBMITTED" : "DRAFT";

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();

            if (appId <= 0)
            {
                const string sql = @"
                    INSERT INTO hrm_leave_applications
                        (emp_name,emp_code,faculty_dept,office_location,position_held,
                         residence_address,mobile_contact,nok_name,nok_address,nok_mobile,
                         leave_type,leave_from,leave_to,num_days,substitute_arrangement,
                         supervisor_username,supervisor_name,status,
                         employee_submitted_at,created_by,created_at,updated_at)
                    VALUES
                        (@en,@ec,@fd,@ol,@ph,@ra,@mc,@nn,@na,@nm,
                         @lt,@lf,@lt2,@nd,@sa,@su,@sn,@st,@sub_at,@cb,NOW(),NOW())";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    BindDraftParams(cmd, empName, numDays, dtFrom, dtTo, newStatus, supUser, supName, username, submit);
                    cmd.ExecuteNonQuery();
                    appId = (int)cmd.LastInsertedId;
                }
            }
            else
            {
                string existStatus = "", existCreator = "";
                using (var cmd = new MySqlCommand(
                    "SELECT status,created_by FROM hrm_leave_applications WHERE id=@id AND is_active=1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", appId);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) { Err("Application not found."); return; }
                        existStatus = dr[0].ToString(); existCreator = dr[1].ToString();
                    }
                }
                if (existStatus != "DRAFT") { Err("Only DRAFT applications can be edited."); return; }
                if (!isAdmin && !string.Equals(existCreator, username, StringComparison.OrdinalIgnoreCase))
                { Err("Permission denied."); return; }

                const string upd = @"
                    UPDATE hrm_leave_applications SET
                        emp_name=@en,emp_code=@ec,faculty_dept=@fd,office_location=@ol,position_held=@ph,
                        residence_address=@ra,mobile_contact=@mc,nok_name=@nn,nok_address=@na,nok_mobile=@nm,
                        leave_type=@lt,leave_from=@lf,leave_to=@lt2,num_days=@nd,substitute_arrangement=@sa,
                        supervisor_username=@su,supervisor_name=@sn,status=@st,
                        employee_submitted_at=@sub_at,updated_at=NOW()
                    WHERE id=@id";
                using (var cmd = new MySqlCommand(upd, conn))
                {
                    BindDraftParams(cmd, empName, numDays, dtFrom, dtTo, newStatus, supUser, supName, username, submit);
                    cmd.Parameters.AddWithValue("@id", appId);
                    cmd.ExecuteNonQuery();
                }
            }

            LogAudit(conn, appId,
                submit ? "SUBMITTED" : "DRAFT_SAVED",
                "DRAFT", newStatus, screenName, username, "Employee",
                submit ? "Application submitted for HOD approval." : "Draft saved.", ip);
        }

        Response.Write("{\"ok\":true,\"id\":" + appId + "}");
    }

    private static void BindDraftParams(MySqlCommand cmd, string empName, int numDays,
        DateTime dtFrom, DateTime dtTo, string newStatus,
        string supUser, string supName, string username, bool submit)
    {
        cmd.Parameters.AddWithValue("@en",     empName);
        cmd.Parameters.AddWithValue("@ec",     HttpContext.Current.Request.Form["emp_code"] ?? "");
        cmd.Parameters.AddWithValue("@fd",     HttpContext.Current.Request.Form["faculty_dept"] ?? "");
        cmd.Parameters.AddWithValue("@ol",     HttpContext.Current.Request.Form["office_location"] ?? "");
        cmd.Parameters.AddWithValue("@ph",     HttpContext.Current.Request.Form["position_held"] ?? "");
        cmd.Parameters.AddWithValue("@ra",     HttpContext.Current.Request.Form["residence_address"] ?? "");
        cmd.Parameters.AddWithValue("@mc",     HttpContext.Current.Request.Form["mobile_contact"] ?? "");
        cmd.Parameters.AddWithValue("@nn",     HttpContext.Current.Request.Form["nok_name"] ?? "");
        cmd.Parameters.AddWithValue("@na",     HttpContext.Current.Request.Form["nok_address"] ?? "");
        cmd.Parameters.AddWithValue("@nm",     HttpContext.Current.Request.Form["nok_mobile"] ?? "");
        cmd.Parameters.AddWithValue("@lt",     HttpContext.Current.Request.Form["leave_type"] ?? "annual");
        cmd.Parameters.AddWithValue("@lf",     dtFrom.ToString("yyyy-MM-dd"));
        cmd.Parameters.AddWithValue("@lt2",    dtTo.ToString("yyyy-MM-dd"));
        cmd.Parameters.AddWithValue("@nd",     numDays);
        cmd.Parameters.AddWithValue("@sa",     HttpContext.Current.Request.Form["substitute_arrangement"] ?? "");
        cmd.Parameters.AddWithValue("@su",     supUser);
        cmd.Parameters.AddWithValue("@sn",     supName);
        cmd.Parameters.AddWithValue("@st",     newStatus);
        cmd.Parameters.AddWithValue("@sub_at", submit ? (object)DateTime.Now : DBNull.Value);
        cmd.Parameters.AddWithValue("@cb",     username);
    }

    // ── HOD Approve ────────────────────────────────────────────────────────────

    private void AjaxHodApprove(string username, string screenName, string ip, bool isAdmin, bool isHod)
    {
        if (!isAdmin && !isHod) { Err("Access denied."); return; }
        int    appId      = FormInt("id");
        string handoverTo = FormStr("hod_handover_to");
        string notes      = FormStr("hod_notes");

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string status = "", supUser = "";
            using (var cmd = new MySqlCommand(
                "SELECT status,supervisor_username FROM hrm_leave_applications WHERE id=@id AND is_active=1", conn))
            {
                cmd.Parameters.AddWithValue("@id", appId);
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) { Err("Application not found."); return; }
                    status = dr[0].ToString(); supUser = dr[1].ToString();
                }
            }
            if (status != "SUBMITTED") { Err("Application is not in SUBMITTED status."); return; }
            if (!isAdmin && !string.Equals(supUser, username, StringComparison.OrdinalIgnoreCase))
            { Err("You are not the assigned supervisor for this application."); return; }

            using (var cmd = new MySqlCommand(@"
                UPDATE hrm_leave_applications SET
                    status='HOD_APPROVED',hod_action='APPROVED',
                    hod_handover_to=@ht,hod_notes=@no,
                    hod_actor=@ac,hod_actor_name=@an,hod_action_at=NOW(),updated_at=NOW()
                WHERE id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@ht", handoverTo);
                cmd.Parameters.AddWithValue("@no", notes);
                cmd.Parameters.AddWithValue("@ac", username);
                cmd.Parameters.AddWithValue("@an", screenName);
                cmd.Parameters.AddWithValue("@id", appId);
                cmd.ExecuteNonQuery();
            }
            LogAudit(conn, appId, "HOD_APPROVED", "SUBMITTED", "HOD_APPROVED",
                screenName, username, "HOD / Supervisor",
                string.IsNullOrEmpty(notes) ? null : notes, ip);
        }
        Response.Write("{\"ok\":true}");
    }

    // ── HOD Decline ────────────────────────────────────────────────────────────

    private void AjaxHodDecline(string username, string screenName, string ip, bool isAdmin, bool isHod)
    {
        if (!isAdmin && !isHod) { Err("Access denied."); return; }
        int    appId  = FormInt("id");
        string reason = FormStr("reason");
        if (string.IsNullOrEmpty(reason)) { Err("A reason is required."); return; }

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string status = "", supUser = "";
            using (var cmd = new MySqlCommand(
                "SELECT status,supervisor_username FROM hrm_leave_applications WHERE id=@id AND is_active=1", conn))
            {
                cmd.Parameters.AddWithValue("@id", appId);
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) { Err("Application not found."); return; }
                    status = dr[0].ToString(); supUser = dr[1].ToString();
                }
            }
            if (status != "SUBMITTED") { Err("Application is not in SUBMITTED status."); return; }
            if (!isAdmin && !string.Equals(supUser, username, StringComparison.OrdinalIgnoreCase))
            { Err("You are not the assigned supervisor."); return; }

            using (var cmd = new MySqlCommand(@"
                UPDATE hrm_leave_applications SET
                    status='HOD_DECLINED',hod_action='DECLINED',
                    hod_notes=@no,hod_actor=@ac,hod_actor_name=@an,
                    hod_action_at=NOW(),updated_at=NOW()
                WHERE id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@no", reason);
                cmd.Parameters.AddWithValue("@ac", username);
                cmd.Parameters.AddWithValue("@an", screenName);
                cmd.Parameters.AddWithValue("@id", appId);
                cmd.ExecuteNonQuery();
            }
            LogAudit(conn, appId, "HOD_DECLINED", "SUBMITTED", "HOD_DECLINED",
                screenName, username, "HOD / Supervisor", reason, ip);
        }
        Response.Write("{\"ok\":true}");
    }

    // ── HR Approve ─────────────────────────────────────────────────────────────

    private void AjaxHrApprove(string username, string screenName, string ip, bool isAdmin, bool isHr)
    {
        if (!isAdmin && !isHr) { Err("Access denied."); return; }
        int    appId  = FormInt("id");
        string effFrom = FormStr("hr_effective_from");
        string effTo   = FormStr("hr_effective_to");
        string notes   = FormStr("hr_notes");

        DateTime dtFrom, dtTo;
        if (!DateTime.TryParse(effFrom, out dtFrom) || !DateTime.TryParse(effTo, out dtTo))
        { Err("Effective dates are required."); return; }

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string status = GetStatus(conn, appId);
            if (status == null) { Err("Application not found."); return; }
            if (status != "HOD_APPROVED") { Err("Application must be in HOD_APPROVED status."); return; }

            using (var cmd = new MySqlCommand(@"
                UPDATE hrm_leave_applications SET
                    status='HR_APPROVED',hr_action='APPROVED',
                    hr_effective_from=@ef,hr_effective_to=@et,hr_notes=@no,
                    hr_actor=@ac,hr_actor_name=@an,hr_action_at=NOW(),updated_at=NOW()
                WHERE id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@ef", dtFrom.ToString("yyyy-MM-dd"));
                cmd.Parameters.AddWithValue("@et", dtTo.ToString("yyyy-MM-dd"));
                cmd.Parameters.AddWithValue("@no", notes);
                cmd.Parameters.AddWithValue("@ac", username);
                cmd.Parameters.AddWithValue("@an", screenName);
                cmd.Parameters.AddWithValue("@id", appId);
                cmd.ExecuteNonQuery();
            }
            LogAudit(conn, appId, "HR_APPROVED", "HOD_APPROVED", "HR_APPROVED",
                screenName, username, "HR Department",
                string.IsNullOrEmpty(notes) ? null : notes, ip);
        }
        Response.Write("{\"ok\":true}");
    }

    // ── HR Decline ─────────────────────────────────────────────────────────────

    private void AjaxHrDecline(string username, string screenName, string ip, bool isAdmin, bool isHr)
    {
        if (!isAdmin && !isHr) { Err("Access denied."); return; }
        int    appId  = FormInt("id");
        string reason = FormStr("reason");
        if (string.IsNullOrEmpty(reason)) { Err("A reason is required."); return; }

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string status = GetStatus(conn, appId);
            if (status == null) { Err("Application not found."); return; }
            if (status != "HOD_APPROVED") { Err("Application must be HOD_APPROVED."); return; }

            using (var cmd = new MySqlCommand(@"
                UPDATE hrm_leave_applications SET
                    status='HR_DECLINED',hr_action='DECLINED',
                    hr_notes=@no,hr_actor=@ac,hr_actor_name=@an,
                    hr_action_at=NOW(),updated_at=NOW()
                WHERE id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@no", reason);
                cmd.Parameters.AddWithValue("@ac", username);
                cmd.Parameters.AddWithValue("@an", screenName);
                cmd.Parameters.AddWithValue("@id", appId);
                cmd.ExecuteNonQuery();
            }
            LogAudit(conn, appId, "HR_DECLINED", "HOD_APPROVED", "HR_DECLINED",
                screenName, username, "HR Department", reason, ip);
        }
        Response.Write("{\"ok\":true}");
    }

    // ── VC Decision ────────────────────────────────────────────────────────────

    private void AjaxVcDecision(string username, string screenName, string roleCode,
        string ip, bool isAdmin, bool isVc)
    {
        if (!isAdmin && !isVc) { Err("Access denied."); return; }
        int    appId    = FormInt("id");
        string decision = FormStr("vc_decision").ToUpper();
        string reason   = FormStr("vc_reason");
        int    accum    = FormInt("vc_accumulated_days");
        int    taken    = FormInt("vc_days_taken");

        string[] valid = { "GRANTED", "NOT_GRANTED", "POSTPONED" };
        if (Array.IndexOf(valid, decision) < 0) { Err("Invalid decision value."); return; }
        if (decision != "GRANTED" && string.IsNullOrEmpty(reason))
        { Err("A reason is required for this decision."); return; }

        string newStatus = "VC_" + decision;

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string status = GetStatus(conn, appId);
            if (status == null) { Err("Application not found."); return; }
            if (status != "HR_APPROVED") { Err("Application must be HR_APPROVED."); return; }

            using (var cmd = new MySqlCommand(@"
                UPDATE hrm_leave_applications SET
                    status=@ns,vc_decision=@vd,vc_reason=@vr,
                    vc_accumulated_days=@va,vc_days_taken=@vt,
                    vc_actor=@ac,vc_actor_name=@an,vc_action_at=NOW(),updated_at=NOW()
                WHERE id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@ns", newStatus);
                cmd.Parameters.AddWithValue("@vd", decision);
                cmd.Parameters.AddWithValue("@vr", string.IsNullOrEmpty(reason) ? (object)DBNull.Value : reason);
                cmd.Parameters.AddWithValue("@va", accum > 0 ? (object)accum : DBNull.Value);
                cmd.Parameters.AddWithValue("@vt", taken > 0 ? (object)taken : DBNull.Value);
                cmd.Parameters.AddWithValue("@ac", username);
                cmd.Parameters.AddWithValue("@an", screenName);
                cmd.Parameters.AddWithValue("@id", appId);
                cmd.ExecuteNonQuery();
            }
            LogAudit(conn, appId, "VC_" + decision, "HR_APPROVED", newStatus,
                screenName, username, "Vice Chancellor's Office",
                string.IsNullOrEmpty(reason) ? null : reason, ip);
        }
        Response.Write("{\"ok\":true}");
    }

    // ── Cancel ─────────────────────────────────────────────────────────────────

    private void AjaxCancel(string username, string screenName, string roleCode,
        string ip, bool isAdmin, bool isHr)
    {
        if (!isAdmin && !isHr) { Err("Only Admin or HR can cancel applications."); return; }
        int appId = FormInt("id");

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string status = GetStatus(conn, appId);
            if (status == null) { Err("Application not found."); return; }
            if (status == "CANCELLED") { Err("Already cancelled."); return; }

            using (var cmd = new MySqlCommand(
                "UPDATE hrm_leave_applications SET status='CANCELLED',updated_at=NOW() WHERE id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", appId);
                cmd.ExecuteNonQuery();
            }
            LogAudit(conn, appId, "CANCELLED", status, "CANCELLED",
                screenName, username, roleCode, "Application cancelled.", ip);
        }
        Response.Write("{\"ok\":true}");
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  SUPERVISOR OPTIONS
    // ══════════════════════════════════════════════════════════════════════════

    private string LoadSupervisorOptions()
    {
        var sb = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                const string sql = @"
                    SELECT DISTINCT ur.username,
                        COALESCE(e.emp_name, ur.username) AS sup_name
                    FROM sys_user_roles ur
                    JOIN sys_roles r ON r.id=ur.role_id
                        AND r.role_code IN ('dean','registrar','hr_manager','admin','hod')
                    LEFT JOIN hrm_employee e ON e.username=ur.username
                    WHERE ur.is_active=1
                    ORDER BY sup_name";

                using (var cmd = new MySqlCommand(sql, conn))
                using (var dr  = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string uname = dr[0].ToString();
                        string disp  = dr[1].ToString();
                        sb.AppendFormat("<option value=\"{0}\">{1}</option>",
                            HttpUtility.HtmlAttributeEncode(uname),
                            HttpUtility.HtmlEncode(disp));
                    }
                }
            }
        }
        catch
        {
            // Fallback: just query usernames without employee name join
            try
            {
                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    const string sql = @"
                        SELECT DISTINCT ur.username FROM sys_user_roles ur
                        JOIN sys_roles r ON r.id=ur.role_id
                            AND r.role_code IN ('dean','registrar','hr_manager','admin','hod')
                        WHERE ur.is_active=1 ORDER BY ur.username";
                    using (var cmd = new MySqlCommand(sql, conn))
                    using (var dr  = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string u = dr[0].ToString();
                            sb.AppendFormat("<option value=\"{0}\">{0}</option>",
                                HttpUtility.HtmlAttributeEncode(u));
                        }
                    }
                }
            }
            catch { /* silent */ }
        }
        return sb.ToString();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  DB HELPERS
    // ══════════════════════════════════════════════════════════════════════════

    private Dictionary<string, object> LoadApp(int appId)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT * FROM hrm_leave_applications WHERE id=@id AND is_active=1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", appId);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return null;
                        var d = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                        for (int i = 0; i < dr.FieldCount; i++)
                            d[dr.GetName(i)] = dr.IsDBNull(i) ? null : dr.GetValue(i);
                        return d;
                    }
                }
            }
        }
        catch { return null; }
    }

    private static string GetStatus(MySqlConnection conn, int appId)
    {
        using (var cmd = new MySqlCommand(
            "SELECT status FROM hrm_leave_applications WHERE id=@id AND is_active=1", conn))
        {
            cmd.Parameters.AddWithValue("@id", appId);
            using (var dr = cmd.ExecuteReader())
                return dr.Read() ? dr[0].ToString() : null;
        }
    }

    private static void LogAudit(MySqlConnection conn, int appId,
        string actionCode, string oldStatus, string newStatus,
        string actorName, string actorUsername, string actorRole, string remarks, string ip)
    {
        try
        {
            const string sql = @"
                INSERT INTO hrm_leave_audit
                    (application_id,action_code,old_status,new_status,
                     actor_name,actor_username,actor_role,remarks,ip_address,created_at)
                VALUES(@ai,@ac,@os,@ns,@an,@au,@ar,@rm,@ip,NOW())";
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ai", appId);
                cmd.Parameters.AddWithValue("@ac", actionCode);
                cmd.Parameters.AddWithValue("@os", string.IsNullOrEmpty(oldStatus) ? (object)DBNull.Value : oldStatus);
                cmd.Parameters.AddWithValue("@ns", string.IsNullOrEmpty(newStatus) ? (object)DBNull.Value : newStatus);
                cmd.Parameters.AddWithValue("@an", actorName);
                cmd.Parameters.AddWithValue("@au", actorUsername);
                cmd.Parameters.AddWithValue("@ar", actorRole);
                cmd.Parameters.AddWithValue("@rm", string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks);
                cmd.Parameters.AddWithValue("@ip", ip ?? "");
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* audit must never break main flow */ }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  HTML HELPERS
    // ══════════════════════════════════════════════════════════════════════════

    private static string LfField(string label, string id, string type, string value, string placeholder)
    {
        return string.Format(
            "<div class=\"lf-field\"><label>{0}</label>" +
            "<input type=\"{1}\" id=\"{2}\" value=\"{3}\" placeholder=\"{4}\" /></div>",
            HttpUtility.HtmlEncode(label), type, id,
            HttpUtility.HtmlAttributeEncode(value ?? ""),
            HttpUtility.HtmlAttributeEncode(placeholder ?? ""));
    }

    private static string LfTextarea(string label, string id, string value, string placeholder)
    {
        return string.Format(
            "<div class=\"lf-field\"><label>{0}</label>" +
            "<textarea id=\"{1}\" placeholder=\"{2}\">{3}</textarea></div>",
            HttpUtility.HtmlEncode(label), id,
            HttpUtility.HtmlAttributeEncode(placeholder ?? ""),
            HttpUtility.HtmlEncode(value ?? ""));
    }

    private static string RoField(string label, string value)
    {
        bool empty = string.IsNullOrWhiteSpace(value);
        return string.Format(
            "<div class=\"lf-field\"><label>{0}</label>" +
            "<div class=\"lf-read-val{1}\">{2}</div></div>",
            HttpUtility.HtmlEncode(label),
            empty ? " lf-read-val--empty" : "",
            empty ? "&mdash;" : HttpUtility.HtmlEncode(value));
    }

    private static string SectionLocked(string num, string title, string reason)
    {
        return string.Format(
            "<div class=\"lf-section lf-section--locked\">" +
            "<div class=\"lf-section__head\">" +
            "<div class=\"lf-section__num\">{0}</div>" +
            "<div class=\"lf-section__title\">{1}</div>" +
            "<span class=\"lf-section__badge badge--locked\">Locked</span>" +
            "</div>" +
            "<div class=\"lf-section__body\">" +
            "<p style=\"font-size:12px;color:var(--muted);margin:0;\">{2}</p>" +
            "</div></div>",
            num, HttpUtility.HtmlEncode(title), HttpUtility.HtmlEncode(reason));
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  BADGE / LABEL HELPERS
    // ══════════════════════════════════════════════════════════════════════════

    private static string StatusBadge(string status)
    {
        string cls, label;
        switch (status)
        {
            case "DRAFT":          cls = "draft";           label = "Draft";        break;
            case "SUBMITTED":      cls = "submitted";       label = "Pending HOD";  break;
            case "HOD_APPROVED":   cls = "hod_approved";   label = "Pending HR";   break;
            case "HOD_DECLINED":   cls = "hod_declined";   label = "HOD Declined"; break;
            case "HR_APPROVED":    cls = "hr_approved";    label = "Pending VC";   break;
            case "HR_DECLINED":    cls = "hr_declined";    label = "HR Declined";  break;
            case "VC_GRANTED":     cls = "vc_granted";     label = "Granted";      break;
            case "VC_NOT_GRANTED": cls = "vc_not_granted"; label = "Not Granted";  break;
            case "VC_POSTPONED":   cls = "vc_postponed";   label = "Postponed";    break;
            case "CANCELLED":      cls = "cancelled";      label = "Cancelled";    break;
            default:               cls = "draft";           label = status;         break;
        }
        return string.Format("<span class=\"lf-status lf-status--{0}\">{1}</span>", cls, label);
    }

    private static string LeaveTypeLabel(string type)
    {
        switch (type)
        {
            case "annual":      return "Annual Leave";
            case "study":       return "Study Leave";
            case "sick":        return "Sick Leave";
            case "maternity":   return "Maternity Leave";
            case "bereavement": return "Family Bereavement";
            default:            return type;
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  DATA UTILITIES
    // ══════════════════════════════════════════════════════════════════════════

    private static string S(Dictionary<string, object> d, string key)
    {
        object v; return d.TryGetValue(key, out v) && v != null ? v.ToString() : "";
    }
    private static int N(Dictionary<string, object> d, string key)
    {
        object v; int i = 0;
        if (d.TryGetValue(key, out v) && v != null && !(v is DBNull)) int.TryParse(v.ToString(), out i);
        return i;
    }
    private static string DateVal(Dictionary<string, object> d, string key)
    {
        object v;
        if (!d.TryGetValue(key, out v) || v == null || v is DBNull) return "";
        DateTime dt; if (v is DateTime) dt = (DateTime)v;
        else if (!DateTime.TryParse(v.ToString(), out dt)) return "";
        return dt.ToString("yyyy-MM-dd");
    }
    private static string FormatDate(Dictionary<string, object> d, string key)
    {
        object v;
        if (!d.TryGetValue(key, out v) || v == null || v is DBNull) return "";
        DateTime dt; if (v is DateTime) dt = (DateTime)v;
        else if (!DateTime.TryParse(v.ToString(), out dt)) return "";
        return dt.ToString("dd MMM yyyy");
    }
    private static string FormatDateTime(Dictionary<string, object> d, string key)
    {
        object v;
        if (!d.TryGetValue(key, out v) || v == null || v is DBNull) return "";
        DateTime dt; if (v is DateTime) dt = (DateTime)v;
        else if (!DateTime.TryParse(v.ToString(), out dt)) return "";
        return dt.ToString("dd MMM yyyy, h:mm tt");
    }

    private string FormStr(string key) { return (Request.Form[key] ?? "").Trim(); }
    private int    FormInt(string key) { int v = 0; int.TryParse(FormStr(key), out v); return v; }

    private void Err(string msg)
    {
        Response.Write("{\"ok\":false,\"error\":" + JsonStr(msg) + "}");
    }

    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                        .Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
    }

    private static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        cs = ConfigurationManager.ConnectionStrings["DefaultConnection"];
        if (cs != null) return cs.ConnectionString;
        throw new InvalidOperationException("No valid connection string.");
    }
}
