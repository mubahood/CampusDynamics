using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AppraisalPrint : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private int QsRecord
    {
        get { int v; return int.TryParse(Request.QueryString["rid"] ?? "0", out v) && v > 0 ? v : 0; }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        if (QsRecord <= 0) { Response.Redirect("~/NewScreens/AppraisalView.aspx", true); return; }
        if (!IsPostBack) RenderPrintContent(QsRecord);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MAIN RENDERER
    // ═══════════════════════════════════════════════════════════════════
    private void RenderPrintContent(int rid)
    {
        DataTable dtRec = LoadMainRecord(rid);

        if (dtRec.Rows.Count == 0)
        {
            litContent.Text = "<p style='padding:20pt;'>Appraisal record not found.</p>";
            return;
        }

        DataRow r       = dtRec.Rows[0];
        string staffCat = SafeStr(r["staff_category"]).ToUpper();
        string empName  = SafeStr(r["emp_name"]);
        string status   = SafeStr(r["status"]).ToUpper();
        string period   = FmtDate(r["period_start"]) + " — " + FmtDate(r["period_end"]);
        string session  = SafeStr(r["session_title"]);

        string formTitle;
        if      (staffCat == "ACADEMIC")       formTitle = "ACADEMIC STAFF PERFORMANCE APPRAISAL FORM";
        else if (staffCat == "ADMINISTRATIVE") formTitle = "ADMINISTRATIVE STAFF PERFORMANCE APPRAISAL FORM";
        else if (staffCat == "SUPPORT")        formTitle = "SUPPORT STAFF PERFORMANCE APPRAISAL FORM";
        else                                   formTitle = "STAFF PERFORMANCE APPRAISAL FORM";

        litPageTitle.Text = HttpUtility.HtmlEncode(empName);
        litEmpRef.Text    = "Ref: " + HttpUtility.HtmlEncode(SafeStr(r["EMP_CODE"]));
        litFormTitle.Text = formTitle;
        litPeriod.Text    = HttpUtility.HtmlEncode(period);
        litSession.Text   = HttpUtility.HtmlEncode(session);

        // Section B
        DataTable dtB = ExecuteQuery(
            @"SELECT slot_number, agreed_output, performance_indicators, result_areas,
                     self_rating, supervisor_rating, comments
              FROM appraisal_section_b WHERE record_id = @rid ORDER BY slot_number",
            new MySqlParameter("@rid", rid));

        // Section C — try with optional supervisor_comment column
        DataTable dtC;
        try
        {
            dtC = ExecuteQuery(
                @"SELECT competency_code, competency_name, category_name, rating, is_na, comment,
                         IFNULL(supervisor_comment,'') AS supervisor_comment
                  FROM appraisal_section_c WHERE record_id = @rid ORDER BY entry_id",
                new MySqlParameter("@rid", rid));
        }
        catch
        {
            dtC = ExecuteQuery(
                @"SELECT competency_code, competency_name, category_name, rating, is_na, comment,
                         '' AS supervisor_comment
                  FROM appraisal_section_c WHERE record_id = @rid ORDER BY entry_id",
                new MySqlParameter("@rid", rid));
        }

        DataTable dtD = ExecuteQuery(
            "SELECT performance_gap, agreed_action, time_frame FROM appraisal_section_d WHERE record_id = @rid ORDER BY entry_id",
            new MySqlParameter("@rid", rid));

        DataTable dtE = ExecuteQuery(
            "SELECT question_number, question_text, response FROM appraisal_section_e WHERE record_id = @rid ORDER BY question_number",
            new MySqlParameter("@rid", rid));

        StringBuilder html = new StringBuilder();

        RenderPreamble(html, staffCat);
        RenderSectionA(html, r, staffCat);
        RenderSectionB(html, dtB, staffCat);
        RenderSectionC(html, dtC, staffCat);
        RenderSectionD(html, dtD);
        RenderSectionE(html, r, dtE, staffCat);
        RenderScoreSummary(html, r, staffCat);
        if (status == "HR_REVIEWED")
            RenderHrReview(html, r, staffCat);
        RenderSignatures(html, r, staffCat);

        litContent.Text = html.ToString();
    }

    // ─── Load main record with contract details (with fallback) ──────────
    private DataTable LoadMainRecord(int rid)
    {
        // Primary: full join with contract, department, jobs
        try
        {
            return ExecuteQuery(
                @"SELECT ar.*,
                         e.emp_name, e.EMP_CODE, e.EmpType,
                         IFNULL(e.emp_email,'') AS emp_email,
                         IFNULL(e.emp_phone,'') AS emp_phone,
                         IFNULL(d.dept_name,'') AS department,
                         IFNULL(j.jobname,'') AS designation,
                         c.contractStart AS contract_start,
                         c.contractEnd   AS contract_end,
                         IFNULL(c.contract_type,'') AS contract_type,
                         IFNULL(c.contractStatus,'') AS contractStatus,
                         IFNULL(rev.emp_name,'Not Assigned') AS reviewer_name,
                         IFNULL(revj.jobname,'') AS reviewer_designation,
                         s.session_title, s.period_start, s.period_end
                  FROM appraisal_records ar
                  INNER JOIN hrm_employee e   ON e.empID = ar.employee_id
                  LEFT JOIN hrm_emp_contracts c ON c.ID = (
                      SELECT c2.ID FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
                      ORDER BY (CASE WHEN c2.contractStatus='VALID' THEN 0 ELSE 1 END),
                               c2.contractStart DESC LIMIT 1)
                  LEFT JOIN hrm_departments d  ON d.ID = c.departmentID
                  LEFT JOIN hrm_jobs j          ON j.ID = c.jobID
                  LEFT JOIN hrm_employee rev   ON rev.empID = ar.reviewer_id
                  LEFT JOIN hrm_emp_contracts revc ON revc.ID = (
                      SELECT c2.ID FROM hrm_emp_contracts c2 WHERE c2.empID = rev.empID
                      ORDER BY (CASE WHEN c2.contractStatus='VALID' THEN 0 ELSE 1 END),
                               c2.contractStart DESC LIMIT 1)
                  LEFT JOIN hrm_jobs revj       ON revj.ID = revc.jobID
                  INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
                  WHERE ar.record_id = @rid",
                new MySqlParameter("@rid", rid));
        }
        catch
        {
            // Fallback: no contract tables
            string deptExpr  = GetDeptExprSimple("e");
            string desigExpr = GetDesigExprSimple("e");
            string revDesig  = GetDesigExprSimple("rev");
            return ExecuteQuery(string.Format(
                @"SELECT ar.*,
                         e.emp_name, e.EMP_CODE, e.EmpType,
                         IFNULL(e.emp_email,'') AS emp_email,
                         IFNULL(e.emp_phone,'') AS emp_phone,
                         {0} AS department, {1} AS designation,
                         NULL AS contract_start, NULL AS contract_end,
                         '' AS contract_type, '' AS contractStatus,
                         IFNULL(rev.emp_name,'Not Assigned') AS reviewer_name,
                         {2} AS reviewer_designation,
                         s.session_title, s.period_start, s.period_end
                  FROM appraisal_records ar
                  INNER JOIN hrm_employee e  ON e.empID = ar.employee_id
                  LEFT JOIN  hrm_employee rev ON rev.empID = ar.reviewer_id
                  INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
                  WHERE ar.record_id = @rid", deptExpr, desigExpr, revDesig),
                new MySqlParameter("@rid", rid));
        }
    }

    private string GetDeptExprSimple(string alias)
    {
        return string.Format("IFNULL({0}.department, IFNULL({0}.dept, 'Unassigned'))", alias);
    }

    private string GetDesigExprSimple(string alias)
    {
        return string.Format("IFNULL({0}.designation, IFNULL({0}.job_title, IFNULL({0}.EmpType,'')))", alias);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PREAMBLE
    // ═══════════════════════════════════════════════════════════════════
    private void RenderPreamble(StringBuilder html, string staffCat)
    {
        html.Append("<div class='preamble-box'>");
        html.Append("<div class='preamble-title'>Preamble</div>");
        html.Append("<p>Staff Performance Appraisal is part of the Performance Management System of Muteesa I Royal University. " +
            "It is used as a management tool for establishing the extent to which set targets within the overall goals of the University are achieved. " +
            "Through the staff performance appraisal, performance gaps and development needs of an individual employee are identified. " +
            "The appraisal process offers an opportunity to the appraisee and appraiser to dialogue and obtain a feedback on performance. " +
            "This therefore, calls for a participatory approach to the appraisal process. " +
            "The appraiser and appraisee are advised to read the detailed guidelines before filling this form.</p>");
        html.Append("</div>");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SECTION A — PERSONAL INFORMATION
    // ═══════════════════════════════════════════════════════════════════
    private void RenderSectionA(StringBuilder html, DataRow r, string staffCat)
    {
        html.Append("<div class='sec-header'>Section A &mdash; Personal Information " +
            "<span class='sec-header-note'>(To be filled by the Employee)</span></div>");

        string empName      = Enc(SafeStr(r["emp_name"]));
        string empCode      = Enc(SafeStr(r["EMP_CODE"]));
        string dept         = Enc(SafeStr(r["department"]));
        string desig        = Enc(SafeStr(r["designation"]));
        string empEmail     = Enc(SafeStr(r["emp_email"]));
        string empPhone     = Enc(SafeStr(r["emp_phone"]));
        string contractType = Enc(SafeStr(r["contract_type"]));
        string contractStat = Enc(SafeStr(r["contractStatus"]));
        string revName      = Enc(SafeStr(r["reviewer_name"]));
        string revDesig     = Enc(SafeStr(r["reviewer_designation"]));
        string catLabel     = staffCat == "ACADEMIC" ? "Academic"
                            : (staffCat == "ADMINISTRATIVE" ? "Administrative" : "Support");

        string dateStart = r.Table.Columns.Contains("contract_start") && r["contract_start"] != DBNull.Value
            ? Enc(FmtDate(r["contract_start"])) : "";
        string dateEnd   = r.Table.Columns.Contains("contract_end") && r["contract_end"] != DBNull.Value
            ? Enc(FmtDate(r["contract_end"])) : "";

        string nb = "<span class='field-blank'>Not recorded</span>";

        html.Append("<table class='bio-grid'>");

        // Row 1: Name | Staff Code
        BioRow(html, "Employee&#39;s Name",
            !string.IsNullOrEmpty(empName)  ? "<strong>" + empName + "</strong>" : nb,
            "Staff Code / EMP No.",
            !string.IsNullOrEmpty(empCode)  ? empCode : nb);

        // Row 2: Email | Phone
        BioRow(html, "Email Address",
            !string.IsNullOrEmpty(empEmail) ? empEmail : nb,
            "Phone No.",
            !string.IsNullOrEmpty(empPhone) ? empPhone : nb);

        // Row 3: Job Title | Department or Faculty
        if (staffCat == "ACADEMIC")
            BioRow(html, "Job Title / Rank",
                !string.IsNullOrEmpty(desig) ? desig : nb,
                "Faculty / Department",
                !string.IsNullOrEmpty(dept)  ? dept  : nb);
        else
            BioRow(html, "Job Title / Rank",
                !string.IsNullOrEmpty(desig) ? desig : nb,
                "Department / Office",
                !string.IsNullOrEmpty(dept)  ? dept  : nb);

        // Row 4: Terms of Employment | Staff Category
        BioRow(html, "Terms of Employment",
            !string.IsNullOrEmpty(contractType) ? contractType : nb,
            "Staff Category", catLabel);

        // Row 5: Contract Start | Contract End
        BioRow(html, "Date of Joining / Contract Start",
            !string.IsNullOrEmpty(dateStart) ? dateStart : nb,
            "Contract End Date",
            !string.IsNullOrEmpty(dateEnd)   ? dateEnd   : nb);

        // Row 6: Contract Status | Position at Joining
        string statBadge = !string.IsNullOrEmpty(contractStat)
            ? string.Format("<span class='status-chip status-chip--{0}'>{1}</span>",
                contractStat.ToLower(), contractStat)
            : nb;
        BioRow(html, "Contract Status", statBadge,
               "Position at Date of Joining", nb);

        // Row 7: Appraiser Name | Appraiser Title
        BioRow(html, "Appraiser&#39;s Name",
            !string.IsNullOrEmpty(revName)  ? revName  : nb,
            "Appraiser&#39;s Title",
            !string.IsNullOrEmpty(revDesig) ? revDesig : nb);

        html.Append("</table>");

        // Qualifications block
        html.Append("<div class='qual-block'>");
        html.Append("<div class='qual-title'>Qualifications:</div>");
        html.Append("<table class='bio-grid'>");
        html.Append("<thead><tr>" +
            "<th class='qual-th' style='width:75%;'>Award &amp; Institution</th>" +
            "<th class='qual-th' style='width:25%;'>Date Obtained</th>" +
            "</tr></thead><tbody>");
        for (int i = 0; i < 5; i++)
            html.Append("<tr><td style='height:13pt;'>&nbsp;</td><td>&nbsp;</td></tr>");
        html.Append("</tbody></table></div>");

        // Reports To
        html.Append("<div class='reports-to-block'>");
        html.Append("<span class='reports-to-label'>Reports to:</span>");
        html.AppendFormat(
            "&nbsp;&nbsp;Name: <span class='sig-underline'>{0}</span>" +
            "&nbsp;&nbsp;&nbsp;&nbsp;Title: <span class='sig-underline'>{1}</span>",
            !string.IsNullOrEmpty(revName)  ? revName  : "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
            !string.IsNullOrEmpty(revDesig) ? revDesig : "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
        html.Append("</div>");
    }

    private void BioRow(StringBuilder html, string lbl1, string val1, string lbl2, string val2)
    {
        html.AppendFormat(
            "<tr><td class='label'>{0}</td><td>{1}</td><td class='label'>{2}</td><td>{3}</td></tr>",
            lbl1, val1, lbl2, val2);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SECTION B — KEY OUTPUTS
    // ═══════════════════════════════════════════════════════════════════
    private void RenderSectionB(StringBuilder html, DataTable dtB, string staffCat)
    {
        html.Append("<div class='sec-header'>Section B &mdash; Assessment of the Level of Achievement</div>");
        html.Append("<div class='sec-subheader'>This section should be filled by both the Appraiser and the Appraisee</div>");

        int maxSlots = (staffCat == "SUPPORT") ? 5 : 10;
        string ratingScale = (staffCat == "ACADEMIC")
            ? "5 = Exceptional &nbsp;|&nbsp; 4 = Above Expectations &nbsp;|&nbsp; 3 = Satisfactory &nbsp;|&nbsp; 2 = Development Needed &nbsp;|&nbsp; 1 = Unsatisfactory"
            : "5 = Excellent &nbsp;|&nbsp; 4 = Very Good &nbsp;|&nbsp; 3 = Good &nbsp;|&nbsp; 2 = Fair &nbsp;|&nbsp; 1 = Poor";

        html.AppendFormat("<div class='rating-legend'>" +
            "<strong>Rating Scale:</strong> {0} &nbsp;&mdash;&nbsp; Recommended max: <strong>{1}</strong> outputs</div>",
            ratingScale, maxSlots);

        html.Append("<table class='sec-b-table'><thead><tr>");
        html.Append("<th style='width:4%'>#</th>");
        html.Append("<th style='width:26%'>Agreed Key Duties and Outputs</th>");
        html.Append("<th style='width:22%'>Performance Indicators &amp; Targets</th>");
        html.Append("<th style='width:17%'>Result Areas</th>");
        html.Append("<th style='width:8%'>Self<br/>Rating</th>");
        html.Append("<th style='width:8%'>Supervisor<br/>Rating</th>");
        html.Append("<th>Comments</th>");
        html.Append("</tr></thead><tbody>");

        int filledCount = 0, selfTotal = 0, supTotal = 0;

        foreach (DataRow b in dtB.Rows)
        {
            string output = SafeStr(b["agreed_output"]).Trim();
            if (string.IsNullOrEmpty(output)) continue;
            filledCount++;

            int selfR = b["self_rating"]      != DBNull.Value ? Convert.ToInt32(b["self_rating"])      : 0;
            int supR  = b["supervisor_rating"] != DBNull.Value ? Convert.ToInt32(b["supervisor_rating"]) : 0;
            if (selfR > 0) selfTotal += selfR;
            if (supR  > 0) supTotal  += supR;

            html.Append("<tr>");
            html.AppendFormat("<td class='num'>{0}</td>",  filledCount);
            html.AppendFormat("<td>{0}</td>",              Enc(output));
            html.AppendFormat("<td>{0}</td>",              Enc(SafeStr(b["performance_indicators"])));
            html.AppendFormat("<td>{0}</td>",              Enc(SafeStr(b["result_areas"])));
            html.AppendFormat("<td class='num'>{0}</td>",  selfR > 0 ? selfR.ToString() : "&mdash;");
            html.AppendFormat("<td class='num b-rating'>{0}</td>", supR > 0 ? supR.ToString() : "&mdash;");
            html.AppendFormat("<td class='cmnt'>{0}</td>", Enc(SafeStr(b["comments"])));
            html.Append("</tr>");
        }

        if (filledCount == 0)
        {
            html.Append("<tr><td colspan='7' class='empty-row'>No outputs recorded for this appraisal period.</td></tr>");
        }
        else
        {
            int maxB = filledCount * 5;
            html.Append("<tr class='sec-b-total-row'>");
            html.AppendFormat("<td colspan='4' style='text-align:right;'>TOTAL &mdash; {0} output{1} rated</td>",
                filledCount, filledCount == 1 ? "" : "s");
            html.AppendFormat("<td class='num'>{0}</td>",
                selfTotal > 0 ? selfTotal + "&nbsp;/&nbsp;" + maxB : "&mdash;");
            html.AppendFormat("<td class='num b-rating'>{0}</td>",
                supTotal > 0 ? supTotal + "&nbsp;/&nbsp;" + maxB : "&mdash;");
            html.Append("<td></td></tr>");
        }
        html.Append("</tbody></table>");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SECTION C — COMPETENCY ASSESSMENT
    // ═══════════════════════════════════════════════════════════════════
    private void RenderSectionC(StringBuilder html, DataTable dtC, string staffCat)
    {
        html.Append("<div class='sec-header'>Section C &mdash; Assessment of Core Competencies</div>");
        html.Append("<div class='sec-subheader'>This section should be filled by the Appraiser after joint discussions</div>");

        string ratingLegend = (staffCat == "ACADEMIC")
            ? "5=Exceptional &nbsp;|&nbsp; 4=Above Expectations &nbsp;|&nbsp; 3=Satisfactory &nbsp;|&nbsp; 2=Development Needed &nbsp;|&nbsp; 1=Unsatisfactory &nbsp;|&nbsp; N/A=Not Applicable"
            : "5=Excellent &nbsp;|&nbsp; 4=Very Good &nbsp;|&nbsp; 3=Good &nbsp;|&nbsp; 2=Fair &nbsp;|&nbsp; 1=Poor &nbsp;|&nbsp; N/A=Not Applicable";

        string formulaNote;
        if      (staffCat == "ACADEMIC")       formulaNote = "Formula: x &divide; y &times; 100 &nbsp;&mdash;&nbsp; y = 52 criteria &times; 5 = <strong>260</strong> (adjusted for N/A)";
        else if (staffCat == "ADMINISTRATIVE") formulaNote = "Formula: x &divide; y &times; 100 &nbsp;&mdash;&nbsp; y = 22 criteria &times; 5 = <strong>110</strong> (adjusted for N/A)";
        else                                   formulaNote = "Formula: x &divide; y &times; 100 &nbsp;&mdash;&nbsp; y = 25 criteria &times; 5 = <strong>125</strong> (adjusted for N/A)";

        html.AppendFormat("<div class='rating-legend'><strong>Rating:</strong> {0}<br/><em>{1}</em></div>",
            ratingLegend, formulaNote);

        if (dtC.Rows.Count == 0)
        {
            html.Append("<p class='empty-note'>No competencies recorded.</p>");
            return;
        }

        html.Append("<table class='sec-c-table'><thead><tr>");
        html.Append("<th style='width:6%'>Code</th>");
        html.Append("<th>Competency / Criterion</th>");
        html.Append("<th style='width:8%'>Rating</th>");
        html.Append("<th style='width:5%'>N/A</th>");
        html.Append("<th style='width:16%'>Employee Comment</th>");
        html.Append("<th style='width:16%'>Supervisor Comment</th>");
        html.Append("</tr></thead><tbody>");

        List<DataRow> rows = new List<DataRow>();
        foreach (DataRow c in dtC.Rows) rows.Add(c);

        string lastCat       = "";
        int    catRating     = 0, catRatedCount = 0;
        int    totalRating   = 0, naCount = 0;
        bool   showSubtotals = (staffCat == "ACADEMIC" || staffCat == "SUPPORT");

        for (int idx = 0; idx < rows.Count; idx++)
        {
            DataRow c          = rows[idx];
            string  cat        = SafeStr(c["category_name"]);
            string  code       = SafeStr(c["competency_code"]);
            string  name       = SafeStr(c["competency_name"]);
            int     isNa       = c["is_na"] != DBNull.Value ? Convert.ToInt32(c["is_na"]) : 0;
            string  comment    = SafeStr(c["comment"]);
            string  supComment = SafeStr(c["supervisor_comment"]);

            if (cat != lastCat && !string.IsNullOrEmpty(lastCat) && showSubtotals)
                EmitCatSubtotal(html, lastCat, catRating, catRatedCount);

            if (cat != lastCat)
            {
                html.AppendFormat("<tr class='cat-row'><td colspan='6'>{0}</td></tr>", Enc(cat));
                lastCat = cat;
                if (showSubtotals) { catRating = 0; catRatedCount = 0; }
            }

            int    rating = 0;
            string ratingDisp;
            if (isNa == 1)
            {
                ratingDisp = "<em class='na-text'>N/A</em>";
                naCount++;
            }
            else if (c["rating"] != DBNull.Value)
            {
                rating = Convert.ToInt32(c["rating"]);
                if (rating > 0)
                {
                    ratingDisp    = "<strong>" + rating + "</strong>";
                    totalRating   += rating;
                    catRating     += rating;
                    catRatedCount++;
                }
                else { ratingDisp = "<span class='na-text'>&mdash;</span>"; }
            }
            else   { ratingDisp = "<span class='na-text'>&mdash;</span>"; }

            html.Append("<tr>");
            html.AppendFormat("<td class='code'>{0}</td>",           Enc(code));
            html.AppendFormat("<td>{0}</td>",                         Enc(name));
            html.AppendFormat("<td class='num'>{0}</td>",             ratingDisp);
            html.AppendFormat("<td class='na'>{0}</td>",              isNa == 1 ? "&#10003;" : "");
            html.AppendFormat("<td class='cmnt'>{0}</td>",            Enc(comment));
            html.AppendFormat("<td class='cmnt'>{0}</td>",            Enc(supComment));
            html.Append("</tr>");
        }

        if (!string.IsNullOrEmpty(lastCat) && showSubtotals)
            EmitCatSubtotal(html, lastCat, catRating, catRatedCount);

        int ratedCount  = rows.Count - naCount;
        int adjustedMax = ratedCount * 5;
        html.Append("<tr class='sec-b-total-row' style='background:#dde4f0;'>");
        html.AppendFormat(
            "<td colspan='2' style='text-align:right;'>SECTION C TOTAL &mdash; {0} rated, {1} marked N/A</td>",
            ratedCount, naCount);
        html.AppendFormat("<td class='num b-rating'>{0}&nbsp;/&nbsp;{1}</td>", totalRating, adjustedMax);
        html.Append("<td colspan='3'></td></tr>");
        html.Append("</tbody></table>");
    }

    private void EmitCatSubtotal(StringBuilder html, string catName, int rating, int ratedCount)
    {
        html.Append("<tr class='cat-subtotal'>");
        html.AppendFormat(
            "<td colspan='2' style='text-align:right;'>Subtotal — {0}</td>", Enc(catName));
        html.AppendFormat(
            "<td class='num'>{0}&nbsp;/&nbsp;{1}</td>",
            ratedCount > 0 ? rating.ToString() : "&mdash;",
            ratedCount > 0 ? (ratedCount * 5).ToString() : "?");
        html.Append("<td colspan='3'></td></tr>");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SECTION D — ACTION PLAN
    // ═══════════════════════════════════════════════════════════════════
    private void RenderSectionD(StringBuilder html, DataTable dtD)
    {
        html.Append("<div class='sec-header'>Section D &mdash; Action Plan to Improve Performance</div>");
        html.Append("<p class='sec-instruction'>How would you like Management to assist you improve your performance? " +
            "The action plan may include: Training, Coaching, Mentoring, Attachment, Job Rotation, Counselling, " +
            "and/or provision of other facilities and resources.</p>");

        html.Append("<table class='sec-d-table'><thead><tr>");
        html.Append("<th style='width:5%'>#</th>");
        html.Append("<th style='width:34%'>Performance Gap / Training Need</th>");
        html.Append("<th style='width:41%'>Agreed Action / Intervention</th>");
        html.Append("<th style='width:20%'>Time Frame</th>");
        html.Append("</tr></thead><tbody>");

        int rowNum = 0;
        foreach (DataRow d in dtD.Rows)
        {
            string gap    = SafeStr(d["performance_gap"]).Trim();
            string action = SafeStr(d["agreed_action"]).Trim();
            string tf     = SafeStr(d["time_frame"]).Trim();
            if (string.IsNullOrEmpty(gap) && string.IsNullOrEmpty(action)) continue;
            rowNum++;
            html.Append("<tr>");
            html.AppendFormat("<td class='num'>{0}</td>", rowNum);
            html.AppendFormat("<td>{0}</td>",             Enc(gap));
            html.AppendFormat("<td>{0}</td>",             Enc(action));
            html.AppendFormat("<td>{0}</td>",             Enc(tf));
            html.Append("</tr>");
        }

        if (rowNum == 0)
        {
            for (int i = 1; i <= 4; i++)
                html.AppendFormat(
                    "<tr><td class='num'>{0}</td><td style='height:16pt;'>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>", i);
        }
        html.Append("</tbody></table>");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SECTION E — SELF-REFLECTION / DECLARATION
    // ═══════════════════════════════════════════════════════════════════
    private void RenderSectionE(StringBuilder html, DataRow r, DataTable dtE, string staffCat)
    {
        html.Append("<div class='sec-header'>Section E &mdash; Comments, Recommendations and Signatures</div>");

        if (staffCat == "SUPPORT")
        {
            html.Append("<div class='sec-subheader'>Supervisor&#39;s Performance Remarks</div>");
            html.Append("<div class='lined-box'>&nbsp;</div>");

            html.Append("<div class='sec-subheader' style='margin-top:6pt;'>Declaration by Supervisee</div>");
            string declared = SafeStr(r["support_declaration"]).ToUpper();
            html.Append("<div class='decl-box'>");
            html.AppendFormat(
                "<div style='margin-bottom:6pt;'>I &nbsp;<span class='emp-underline'>{0}</span>&nbsp; " +
                "have read and understood the rating of my Appraisal.</div>",
                Enc(SafeStr(r["emp_name"])));
            html.Append("<div style='margin-top:4pt;'><strong>I therefore:&nbsp;&nbsp;</strong>");
            html.AppendFormat("<span class='decl-option{0}'>&#9634; AGREE</span>",
                declared == "AGREE" ? " decl-checked" : "");
            html.AppendFormat("<span class='decl-option{0}'>&#9634; DISAGREE</span>",
                declared == "DISAGREE" ? " decl-checked" : "");
            html.Append("</div>");
            if (!string.IsNullOrEmpty(declared))
                html.AppendFormat("<div class='decl-recorded'>Recorded as: <strong>{0}</strong></div>", Enc(declared));
            html.Append("</div>");
            return;
        }

        // Academic / Administrative: 6 self-reflection questions
        html.Append("<div class='sec-subheader'>Employee Self-Reflection</div>");

        string[] defaultQs = new string[]
        {
            "Describe how effectively you have been utilized by the University.",
            "What do you consider to be your major strength(s) with respect to your competencies?",
            "List down any work you accomplished in addition to your agreed tasks/responsibilities.",
            "In respect of your Key Performance Areas, what achievement(s) are you particularly pleased with?",
            "Specify any areas where you could not meet the expected standards and give reasons thereof.",
            "What are your aspirations in terms of career development?"
        };

        if (dtE.Rows.Count == 0)
        {
            for (int i = 0; i < defaultQs.Length; i++)
            {
                html.Append("<div class='sec-e-question avoid-break'>");
                html.AppendFormat("<div class='sec-e-qnum'>Q{0}.</div>", i + 1);
                html.AppendFormat("<div class='sec-e-qtext'>{0}</div>", defaultQs[i]);
                html.Append("<div class='sec-e-response sec-e-empty'>(No response provided)</div>");
                html.Append("</div>");
            }
        }
        else
        {
            foreach (DataRow eq in dtE.Rows)
            {
                string response = SafeStr(eq["response"]).Trim();
                html.Append("<div class='sec-e-question avoid-break'>");
                html.AppendFormat("<div class='sec-e-qnum'>Q{0}.</div>", SafeStr(eq["question_number"]));
                html.AppendFormat("<div class='sec-e-qtext'>{0}</div>", Enc(SafeStr(eq["question_text"])));
                if (!string.IsNullOrEmpty(response))
                    html.AppendFormat("<div class='sec-e-response'>{0}</div>", Enc(response));
                else
                    html.Append("<div class='sec-e-response sec-e-empty'>(No response provided)</div>");
                html.Append("</div>");
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SCORE SUMMARY
    // ═══════════════════════════════════════════════════════════════════
    private void RenderScoreSummary(StringBuilder html, DataRow r, string staffCat)
    {
        string pctStr  = SafeStr(r["final_percentage"]);
        string cls     = SafeStr(r["classification"]);
        string rawStr  = SafeStr(r["raw_score"]);
        string maxStr  = SafeStr(r["max_possible"]);
        string bSupStr = SafeStr(r["section_b_supervisor_total"]);
        string bSelStr = SafeStr(r["section_b_self_total"]);
        string cTotStr = SafeStr(r["section_c_total"]);

        if (string.IsNullOrEmpty(pctStr) && string.IsNullOrEmpty(rawStr)) return;

        int bMaxSlots  = (staffCat == "SUPPORT") ? 5 : 8;
        int cCriteria  = (staffCat == "ACADEMIC") ? 52 : ((staffCat == "SUPPORT") ? 25 : 22);

        html.Append("<div class='score-box avoid-break'>");
        html.Append("<div class='score-title'>Overall Performance Score Summary</div>");

        if (!string.IsNullOrEmpty(bSelStr))
            html.AppendFormat(
                "<div class='score-row'>" +
                "<span class='score-label'>Section B &mdash; Employee Self-Assessment</span>" +
                "<span class='score-val'>{0} <em class='score-note'>(for discussion only)</em></span></div>",
                bSelStr);

        if (!string.IsNullOrEmpty(bSupStr))
            html.AppendFormat(
                "<div class='score-row'>" +
                "<span class='score-label'>Section B &mdash; Supervisor Rating Total (max {0})</span>" +
                "<span class='score-val'>{1}</span></div>",
                bMaxSlots * 5, bSupStr);

        if (!string.IsNullOrEmpty(cTotStr))
            html.AppendFormat(
                "<div class='score-row'>" +
                "<span class='score-label'>Section C &mdash; Competency Total (max {0})</span>" +
                "<span class='score-val'>{1}</span></div>",
                cCriteria * 5, cTotStr);

        if (!string.IsNullOrEmpty(rawStr) && !string.IsNullOrEmpty(maxStr))
        {
            html.AppendFormat(
                "<div class='score-row score-row--rule'>" +
                "<span class='score-label'>Raw Score (X) / Adjusted Maximum (Y)</span>" +
                "<span class='score-val'>{0} / {1}</span></div>",
                rawStr, maxStr);

            decimal rawVal, maxVal;
            if (decimal.TryParse(rawStr, out rawVal) && decimal.TryParse(maxStr, out maxVal) && maxVal > 0)
            {
                html.AppendFormat(
                    "<div class='score-row'>" +
                    "<span class='score-label'>Formula &nbsp; X &divide; Y &times; 100</span>" +
                    "<span class='score-val'>{0:F0} &divide; {1:F0} &times; 100 = <strong>{2:F2}%</strong></span></div>",
                    rawVal, maxVal, rawVal / maxVal * 100m);
            }
        }

        if (!string.IsNullOrEmpty(pctStr))
        {
            decimal pctVal;
            decimal.TryParse(pctStr, out pctVal);
            html.AppendFormat(
                "<div class='score-final'>Final Percentage: <strong>{0:F2}%</strong>" +
                "&nbsp;&nbsp;|&nbsp;&nbsp;Classification: <strong>{1}</strong></div>",
                pctVal, !string.IsNullOrEmpty(cls) ? Enc(cls) : "&mdash;");
            html.AppendFormat(
                "<div class='score-band'>{0}</div>",
                ClassificationBand(pctVal));
        }

        html.Append("</div>");
    }

    private string ClassificationBand(decimal pct)
    {
        if (pct >= 90m) return "Exceptional &mdash; Recognition, reward; potential promotion consideration";
        if (pct >= 75m) return "Very Good &mdash; Positive feedback; identify areas for further growth";
        if (pct >= 60m) return "Good &mdash; Meets standard; targeted improvement areas identified";
        if (pct >= 40m) return "Fair &mdash; Performance Improvement Plan (PIP) required";
        return "Unsatisfactory &mdash; Formal PIP with defined timeline; potential consequences";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HR REVIEW
    // ═══════════════════════════════════════════════════════════════════
    private void RenderHrReview(StringBuilder html, DataRow r, string staffCat)
    {
        string hrOfficer = r.Table.Columns.Contains("hr_officer_name")
            ? Enc(SafeStr(r["hr_officer_name"])) : "&mdash;";
        int hrRating = r.Table.Columns.Contains("hr_overall_rating") && r["hr_overall_rating"] != DBNull.Value
            ? Convert.ToInt32(r["hr_overall_rating"]) : 0;
        string hrRec = r.Table.Columns.Contains("hr_recommendation")
            ? Enc(SafeStr(r["hr_recommendation"]).Replace("_", " ")) : "&mdash;";
        string hrComm = r.Table.Columns.Contains("hr_comments")
            ? Enc(SafeStr(r["hr_comments"])) : "";
        string hrAt = r.Table.Columns.Contains("hr_submitted_at") && r["hr_submitted_at"] != DBNull.Value
            ? Enc(Convert.ToDateTime(r["hr_submitted_at"]).ToString("d MMMM yyyy")) : "&mdash;";
        string hrDecl = r.Table.Columns.Contains("support_declaration")
            ? SafeStr(r["support_declaration"]).ToUpper() : "";

        string[] ratingLabels = { "", "1 — Unsatisfactory / Poor", "2 — Development Needed / Fair",
                                      "3 — Satisfactory / Good",   "4 — Very Good / Above Expectations",
                                      "5 — Exceptional / Excellent" };
        string hrRatingLabel = hrRating >= 1 && hrRating <= 5 ? ratingLabels[hrRating] : "&mdash;";

        string declLabel;
        if      (hrDecl == "AGREE")    declLabel = "<strong style='color:#155724;'>&#10003; AGREE</strong>";
        else if (hrDecl == "DISAGREE") declLabel = "<strong style='color:#721c24;'>&#10007; DISAGREE</strong>";
        else                           declLabel = "&mdash;";

        html.Append("<div class='sec-header'>Human Resources Department Review</div>");
        html.Append("<table class='bio-grid'>");
        BioRow(html, "HR Officer",        hrOfficer,     "Review Date",     hrAt);
        BioRow(html, "HR Overall Rating", hrRatingLabel, "Recommendation",  hrRec);
        BioRow(html, "Declaration",       declLabel,     "&nbsp;",          "&nbsp;");
        html.Append("</table>");

        if (!string.IsNullOrEmpty(hrComm))
        {
            html.Append("<div class='hr-comment-box'>");
            html.Append("<strong>HR Comments:</strong><br/>");
            html.Append(hrComm);
            html.Append("</div>");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SIGNATURES
    // ═══════════════════════════════════════════════════════════════════
    private void RenderSignatures(StringBuilder html, DataRow r, string staffCat)
    {
        string empName     = Enc(SafeStr(r["emp_name"]));
        string revName     = Enc(SafeStr(r["reviewer_name"]));
        string revDesig    = Enc(SafeStr(r["reviewer_designation"]));
        string submittedAt = r["employee_submitted_at"]  != DBNull.Value
            ? Convert.ToDateTime(r["employee_submitted_at"]).ToString("d MMM yyyy") : "";
        string completedAt = r["supervisor_submitted_at"] != DBNull.Value
            ? Convert.ToDateTime(r["supervisor_submitted_at"]).ToString("d MMM yyyy") : "";

        html.Append("<div class='sig-block avoid-break'>");
        html.Append("<div class='sig-title'>Comments and Signatures</div>");

        // Appraiser comments
        html.Append("<div class='comment-box'>");
        html.Append("<div class='comment-box__label'>Comments of the Appraiser:</div>");
        html.Append("<div class='comment-box__body'>&nbsp;</div>");
        html.Append("<div class='comment-box__footer'>");
        html.AppendFormat("Name: <span class='sig-underline'>{0}</span>&nbsp;&nbsp;" +
            "Title: <span class='sig-underline'>{1}</span>&nbsp;&nbsp;" +
            "Signature: <span class='sig-underline'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;" +
            "Date: <span class='sig-underline'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>",
            revName, revDesig);
        html.Append("</div></div>");

        // Responsible officer comments
        string roTitle = (staffCat == "ACADEMIC")
            ? "Comments of the Responsible Officer (Dean / HRM / Vice Chancellor / Deputy Vice Chancellor):"
            : "Comments of the HR Manager:";
        html.Append("<div class='comment-box'>");
        html.AppendFormat("<div class='comment-box__label'>{0}</div>", roTitle);
        html.Append("<div class='comment-box__body'>&nbsp;</div>");
        html.Append("<div class='comment-box__footer'>" +
            "Name: <span class='sig-underline'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;" +
            "Title: <span class='sig-underline'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;" +
            "Signature: <span class='sig-underline'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;" +
            "Date: <span class='sig-underline'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" +
            "</div></div>");

        // Three-column signature grid
        html.Append("<div class='sig-grid'>");

        // Appraisee
        html.Append("<div class='sig-item'>");
        html.Append("<div class='role'>Appraisee (Employee)</div>");
        html.AppendFormat("<div class='sig-name'>{0}</div>", empName);
        html.Append("<div class='sig-field-label'>Name</div>");
        html.Append("<div class='sig-line'></div><div class='sig-field-label'>Signature</div>");
        html.Append("<div class='sig-line' style='margin-top:14pt;'></div><div class='sig-field-label'>Date</div>");
        if (!string.IsNullOrEmpty(submittedAt))
            html.AppendFormat("<div class='sig-date'>Submitted: {0}</div>", submittedAt);
        html.Append("</div>");

        // Appraiser
        html.Append("<div class='sig-item'>");
        html.Append("<div class='role'>Appraiser (Supervisor)</div>");
        html.AppendFormat("<div class='sig-name'>{0}</div>", revName);
        if (!string.IsNullOrEmpty(revDesig))
            html.AppendFormat("<div class='sig-field-label'>{0}</div>", revDesig);
        html.Append("<div class='sig-line' style='margin-top:12pt;'></div><div class='sig-field-label'>Signature</div>");
        html.Append("<div class='sig-line' style='margin-top:14pt;'></div><div class='sig-field-label'>Date</div>");
        if (!string.IsNullOrEmpty(completedAt))
            html.AppendFormat("<div class='sig-date'>Completed: {0}</div>", completedAt);
        html.Append("</div>");

        // Responsible Officer
        html.Append("<div class='sig-item'>");
        if (staffCat == "ACADEMIC")
        {
            html.Append("<div class='role'>Responsible Officer</div>");
            html.Append("<div class='sig-field-label'>Dean / VC / DVC / HRM</div>");
        }
        else { html.Append("<div class='role'>HR Manager</div>"); }
        html.Append("<div class='sig-line' style='margin-top:22pt;'></div><div class='sig-field-label'>Name</div>");
        html.Append("<div class='sig-line' style='margin-top:14pt;'></div><div class='sig-field-label'>Signature</div>");
        html.Append("<div class='sig-line' style='margin-top:14pt;'></div><div class='sig-field-label'>Date</div>");
        html.Append("</div>");

        html.Append("</div></div>"); // sig-grid + sig-block
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════
    private string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private string FmtDate(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        DateTime d;
        if (val is DateTime) d = (DateTime)val;
        else if (!DateTime.TryParse(val.ToString(), out d)) return val.ToString();
        return d.ToString("d MMMM yyyy");
    }

    private string Enc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return HttpUtility.HtmlEncode(s).Replace("\n", "<br/>");
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
            }
        }
        return dt;
    }
}
