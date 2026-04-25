using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_ProgrammeLoadRequests : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static string ConnStrStatic
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string CurrentAcadYear
    {
        get
        {
            string value = Session["SelectedAcademicYear"] == null ? "" : Session["SelectedAcademicYear"].ToString();
            if (string.IsNullOrEmpty(value)) value = AcademicYearHelper.GetCurrentAcademicYear();
            return value;
        }
    }

    private string CurrentSemester
    {
        get
        {
            string value = Session["SelectedSemester"] == null ? "" : Session["SelectedSemester"].ToString();
            if (string.IsNullOrEmpty(value)) value = "1";
            return value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            EnsureAllocationRequestColumns(conn);
            LoadProgrammeFilter(conn);
            ApplyQueryToControls();
            litCurrentPeriod.Text = HttpUtility.HtmlEncode(CurrentAcadYear + " / Semester " + CurrentSemester);
            LoadStats(conn);
            BindGrid(conn);
        }
    }

    private static void EnsureAllocationRequestColumns(MySqlConnection conn)
    {
        string[] sqls = new string[]
        {
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_status VARCHAR(3) NULL DEFAULT 'No'",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_lecturer_id INT NULL",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_date DATETIME NULL",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_message TEXT NULL",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_admin_status VARCHAR(20) NULL DEFAULT 'Pending'",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_admin_message TEXT NULL"
        };

        for (int i = 0; i < sqls.Length; i++)
        {
            try { using (MySqlCommand cmd = new MySqlCommand(sqls[i], conn)) cmd.ExecuteNonQuery(); }
            catch { }
        }
    }

    private void LoadProgrammeFilter(MySqlConnection conn)
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new System.Web.UI.WebControls.ListItem("All", ""));

        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT DISTINCT p.progcode, IFNULL(p.progname,p.progcode) AS progname
            FROM acad_programmecourses pc
            LEFT JOIN acad_programme p ON p.progcode = pc.progcode
            WHERE IFNULL(pc.allocation_request_lecturer_id,0) > 0
            ORDER BY progname", conn))
        using (var rdr = cmd.ExecuteReader())
        {
            while (rdr.Read())
            {
                string code = rdr["progcode"] == DBNull.Value ? "" : rdr["progcode"].ToString();
                string name = rdr["progname"] == DBNull.Value ? code : rdr["progname"].ToString();
                if (!string.IsNullOrEmpty(code))
                    ddlProgramme.Items.Add(new System.Web.UI.WebControls.ListItem(name, code));
            }
        }
    }

    private void ApplyQueryToControls()
    {
        SafeSelect(ddlSemester, Request.QueryString["sem"]);
        SafeSelect(ddlProgramme, Request.QueryString["prog"]);
        SafeSelect(ddlStatus, Request.QueryString["status"]);
        SafeSelect(ddlPageSize, Request.QueryString["size"]);
        txtSearch.Text = (Request.QueryString["q"] ?? "").Trim();
    }

    private void SafeSelect(System.Web.UI.WebControls.DropDownList ddl, string value)
    {
        if (string.IsNullOrEmpty(value)) return;
        var item = ddl.Items.FindByValue(value);
        if (item != null) ddl.SelectedValue = value;
    }

    private void LoadStats(MySqlConnection conn)
    {
        string sql = @"
            SELECT
                SUM(CASE WHEN UPPER(IFNULL(allocation_request_admin_status,'Pending'))='PENDING' AND IFNULL(allocation_request_lecturer_id,0) > 0 THEN 1 ELSE 0 END) AS pending_count,
                SUM(CASE WHEN UPPER(IFNULL(allocation_request_admin_status,'Pending'))='APPROVED' THEN 1 ELSE 0 END) AS approved_count,
                SUM(CASE WHEN UPPER(IFNULL(allocation_request_admin_status,'Pending'))='REJECTED' THEN 1 ELSE 0 END) AS rejected_count
            FROM acad_programmecourses";

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        using (var rdr = cmd.ExecuteReader())
        {
            if (rdr.Read())
            {
                litPendingCount.Text = (rdr["pending_count"] == DBNull.Value ? 0 : Convert.ToInt32(rdr["pending_count"])) .ToString("N0");
                litApprovedCount.Text = (rdr["approved_count"] == DBNull.Value ? 0 : Convert.ToInt32(rdr["approved_count"])) .ToString("N0");
                litRejectedCount.Text = (rdr["rejected_count"] == DBNull.Value ? 0 : Convert.ToInt32(rdr["rejected_count"])) .ToString("N0");
            }
        }
    }

    private void BindGrid(MySqlConnection conn)
    {
        string sem = (Request.QueryString["sem"] ?? "").Trim();
        string prog = (Request.QueryString["prog"] ?? "").Trim();
        string status = (Request.QueryString["status"] ?? "").Trim();
        string q = (Request.QueryString["q"] ?? "").Trim();

        int page = ParseInt(Request.QueryString["page"], 1, 1, 1000000);
        int pageSize = ParseInt(Request.QueryString["size"], ParseInt(ddlPageSize.SelectedValue, 50, 1, 200), 1, 200);
        int offset = (page - 1) * pageSize;

        StringBuilder where = new StringBuilder(" WHERE IFNULL(pc.allocation_request_lecturer_id,0) > 0");
        if (!string.IsNullOrEmpty(sem)) where.Append(" AND pc.semester=@sem");
        if (!string.IsNullOrEmpty(prog)) where.Append(" AND pc.progcode=@prog");
        if (!string.IsNullOrEmpty(status)) where.Append(" AND UPPER(IFNULL(pc.allocation_request_admin_status,'Pending'))=@status");
        if (!string.IsNullOrEmpty(q))
        {
            where.Append(" AND (pc.course_code LIKE @q OR IFNULL(c.courseName,'') LIKE @q OR IFNULL(p.progname,'') LIKE @q OR IFNULL(sp.spec,'') LIKE @q OR IFNULL(er.emp_name,'') LIKE @q OR IFNULL(pc.allocation_request_message,'') LIKE @q)");
        }

        string from = @"
            FROM acad_programmecourses pc
            LEFT JOIN acad_course c ON c.courseID = pc.course_code
            LEFT JOIN acad_programme p ON p.progcode = pc.progcode
            LEFT JOIN acad_specialisation sp ON sp.spec_id = pc.specialisation_id
            LEFT JOIN hrm_employee er ON er.empID = pc.allocation_request_lecturer_id
            LEFT JOIN hrm_employee ea ON ea.empID = pc.lecturer_id";

        int totalRows;
        using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) " + from + where.ToString(), conn))
        {
            AddFilters(cmd, sem, prog, status, q);
            totalRows = Convert.ToInt32(cmd.ExecuteScalar());
        }

        int totalPages = totalRows > 0 ? (int)Math.Ceiling(totalRows / (double)pageSize) : 1;
        if (page > totalPages)
        {
            page = totalPages;
            offset = (page - 1) * pageSize;
        }

        string sql = @"
            SELECT pc.ID,
                   pc.course_code,
                   IFNULL(c.courseName,'') AS course_name,
                   pc.progcode,
                   IFNULL(p.progname,pc.progcode) AS programme_name,
                   IFNULL(sp.spec,'-') AS spec_name,
                   IFNULL(pc.study_year,1) AS study_year,
                   IFNULL(pc.semester,1) AS semester,
                   IFNULL(pc.lecturer_id,0) AS assigned_lecturer_id,
                   IFNULL(ea.emp_name,'') AS assigned_lecturer_name,
                   IFNULL(ea.emp_code,'') AS assigned_lecturer_code,
                   IFNULL(pc.allocation_request_lecturer_id,0) AS req_lecturer_id,
                   IFNULL(er.emp_name,'') AS req_lecturer_name,
                   IFNULL(er.emp_code,'') AS req_lecturer_code,
                   IFNULL(pc.allocation_request_message,'') AS req_message,
                   IFNULL(pc.allocation_request_admin_message,'') AS req_admin_message,
                   DATE_FORMAT(pc.allocation_request_date,'%Y-%m-%d %H:%i') AS req_date,
                   IFNULL(pc.allocation_request_admin_status,'Pending') AS req_admin_status
            " + from + where.ToString() + @"
            ORDER BY
                CASE WHEN UPPER(IFNULL(pc.allocation_request_admin_status,'Pending'))='PENDING' THEN 0 ELSE 1 END,
                IFNULL(pc.allocation_request_date,'2000-01-01') DESC,
                pc.course_code ASC
            LIMIT @offset, @pageSize";

        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddFilters(cmd, sem, prog, status, q);
            cmd.Parameters.AddWithValue("@offset", offset);
            cmd.Parameters.AddWithValue("@pageSize", pageSize);
            using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
        }

        if (dt.Rows.Count == 0)
        {
            litRows.Text = "<tr><td colspan='9' class='plr-empty'>No allocation requests found for the selected filters.</td></tr>";
        }
        else
        {
            StringBuilder sb = new StringBuilder();
            foreach (DataRow r in dt.Rows)
            {
                string statusRaw = ToStr(r["req_admin_status"]);
                string statusUpper = statusRaw.ToUpperInvariant();
                string statusClass = statusUpper == "APPROVED" ? "plr-pill--approved" : (statusUpper == "REJECTED" ? "plr-pill--rejected" : "plr-pill--pending");
                string statusText = statusUpper == "" ? "PENDING" : statusUpper;

                string requester = BuildLecturerDisplay(ToStr(r["req_lecturer_name"]), ToStr(r["req_lecturer_code"]), ToStr(r["req_lecturer_id"]));
                string assigned = BuildLecturerDisplay(ToStr(r["assigned_lecturer_name"]), ToStr(r["assigned_lecturer_code"]), ToStr(r["assigned_lecturer_id"]));
                string courseCtx = ToStr(r["course_code"]) + " - " + ToStr(r["course_name"]) + " | " + ToStr(r["programme_name"]) + " | Year " + ToStr(r["study_year"]) + " Sem " + ToStr(r["semester"]);

                string attrCourseCtx = HttpUtility.HtmlAttributeEncode(courseCtx);
                string attrRequester = HttpUtility.HtmlAttributeEncode(requester);
                string attrAssigned = HttpUtility.HtmlAttributeEncode(assigned);
                string attrReqMsg = HttpUtility.HtmlAttributeEncode(ToStr(r["req_message"]));
                string attrAdminMsg = HttpUtility.HtmlAttributeEncode(ToStr(r["req_admin_message"]));

                bool canQuick = statusUpper == "PENDING";

                sb.Append("<tr>");
                sb.Append("<td><input type='checkbox' class='plr-row-check plr-check' data-id='" + H(r["ID"]) + "' /></td>");
                sb.Append("<td><div class='plr-code'>" + H(r["course_code"]) + "</div><div class='plr-muted'>" + H(r["course_name"]) + "</div></td>");
                sb.Append("<td>" + H(r["programme_name"]) + "<div class='plr-muted'>" + H(r["spec_name"]) + " &bull; Year " + H(r["study_year"]) + " / Sem " + H(r["semester"]) + "</div></td>");
                sb.Append("<td>" + H(requester) + "</td>");
                sb.Append("<td>" + H(assigned) + "</td>");
                sb.Append("<td class='plr-muted'>" + H(r["req_date"]) + "</td>");
                sb.Append("<td><div class='plr-muted' style='max-width:260px;white-space:pre-wrap;line-height:1.35;'>" + H(r["req_message"]) + "</div></td>");
                sb.Append("<td><span class='plr-pill " + statusClass + "'>" + H(statusText) + "</span></td>");
                sb.Append("<td><div class='plr-actions'>");
                sb.Append("<button type='button' class='plr-txtbtn' data-id='" + H(r["ID"]) + "' data-coursectx='" + attrCourseCtx + "' data-requester='" + attrRequester + "' data-assigned='" + attrAssigned + "' data-reqmsg='" + attrReqMsg + "' data-adminmsg='" + attrAdminMsg + "' onclick='openReviewModal(this)'>Review</button>");
                if (canQuick)
                {
                    sb.Append("<button type='button' class='plr-txtbtn plr-txtbtn--ok' onclick=\"quickDecision('" + H(r["ID"]) + "','Approved')\">Approve</button>");
                    sb.Append("<button type='button' class='plr-txtbtn plr-txtbtn--danger' onclick=\"quickDecision('" + H(r["ID"]) + "','Rejected')\">Reject</button>");
                }
                sb.Append("</div></td>");
                sb.Append("</tr>");
            }
            litRows.Text = sb.ToString();
        }

        int fromRow = totalRows == 0 ? 0 : (offset + 1);
        int toRow = Math.Min(offset + dt.Rows.Count, totalRows);
        litPageInfo.Text = fromRow + " - " + toRow + " of " + totalRows;
        litTotalRows.Text = totalRows.ToString("N0");
        litTotalDisplay.Text = totalRows.ToString("N0");
        litPager.Text = BuildPager(page, totalPages, sem, prog, status, q, pageSize);
    }

    private string BuildLecturerDisplay(string name, string code, string id)
    {
        if (!string.IsNullOrWhiteSpace(name))
            return name + (string.IsNullOrWhiteSpace(code) ? "" : " (" + code + ")");
        int parsed;
        if (int.TryParse(id, out parsed) && parsed > 0) return "Staff #" + id;
        return "-";
    }

    private string BuildPager(int page, int totalPages, string sem, string prog, string status, string q, int size)
    {
        StringBuilder sb = new StringBuilder();
        if (page > 1) sb.Append("<a href='?page=" + (page - 1) + BuildQs(sem, prog, status, q, size) + "'>&laquo;</a>");

        int start = Math.Max(1, page - 3);
        int end = Math.Min(totalPages, page + 3);
        for (int i = start; i <= end; i++)
        {
            if (i == page) sb.Append("<span class='active'>" + i + "</span>");
            else sb.Append("<a href='?page=" + i + BuildQs(sem, prog, status, q, size) + "'>" + i + "</a>");
        }

        if (page < totalPages) sb.Append("<a href='?page=" + (page + 1) + BuildQs(sem, prog, status, q, size) + "'>&raquo;</a>");
        return sb.ToString();
    }

    private string BuildQs(string sem, string prog, string status, string q, int size)
    {
        StringBuilder sb = new StringBuilder();
        if (!string.IsNullOrEmpty(sem)) sb.Append("&sem=" + HttpUtility.UrlEncode(sem));
        if (!string.IsNullOrEmpty(prog)) sb.Append("&prog=" + HttpUtility.UrlEncode(prog));
        if (!string.IsNullOrEmpty(status)) sb.Append("&status=" + HttpUtility.UrlEncode(status));
        if (!string.IsNullOrEmpty(q)) sb.Append("&q=" + HttpUtility.UrlEncode(q));
        sb.Append("&size=" + size);
        return sb.ToString();
    }

    private void AddFilters(MySqlCommand cmd, string sem, string prog, string status, string q)
    {
        if (!string.IsNullOrEmpty(sem)) cmd.Parameters.AddWithValue("@sem", sem);
        if (!string.IsNullOrEmpty(prog)) cmd.Parameters.AddWithValue("@prog", prog);
        if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@status", status.ToUpperInvariant());
        if (!string.IsNullOrEmpty(q)) cmd.Parameters.AddWithValue("@q", "%" + q + "%");
    }

    private int ParseInt(string raw, int fallback, int min, int max)
    {
        int n;
        if (!int.TryParse(raw, out n)) n = fallback;
        if (n < min) n = min;
        if (n > max) n = max;
        return n;
    }

    private string ToStr(object v)
    {
        return v == null || v == DBNull.Value ? "" : v.ToString();
    }

    private string H(object v)
    {
        return HttpUtility.HtmlEncode(v == null || v == DBNull.Value ? "" : v.ToString());
    }

    public class DecisionResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
    }

    private static DecisionResponse ApplyDecision(MySqlConnection conn, int programmeCourseId, string decision, string adminMessage)
    {
        DecisionResponse resp = new DecisionResponse { Success = false, Message = "Invalid request." };

        if (programmeCourseId <= 0)
        {
            resp.Message = "Invalid request context.";
            return resp;
        }

        string d = (decision ?? "").Trim();
        if (string.IsNullOrEmpty(d)) d = "Pending";
        d = d.Substring(0, 1).ToUpper() + d.Substring(1).ToLower();
        if (d != "Approved" && d != "Rejected" && d != "Pending")
        {
            resp.Message = "Decision must be Approved, Rejected or Pending.";
            return resp;
        }

        string msg = (adminMessage ?? "").Trim();
        if (msg.Length > 1500) msg = msg.Substring(0, 1500);

        int reqLecturerId = 0;
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT IFNULL(allocation_request_lecturer_id,0)
            FROM acad_programmecourses
            WHERE ID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", programmeCourseId);
            object val = cmd.ExecuteScalar();
            if (val == null || val == DBNull.Value)
            {
                resp.Message = "Course context not found.";
                return resp;
            }
            int.TryParse(val.ToString(), out reqLecturerId);
        }

        if (reqLecturerId <= 0)
        {
            resp.Message = "No lecturer request exists for this row.";
            return resp;
        }

        if (d == "Approved")
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                UPDATE acad_programmecourses
                SET lecturer_id=@lid,
                    is_lecturere_assigned='Yes',
                    status='Active',
                    allocation_request_status='Yes',
                    allocation_request_admin_status='Approved',
                    allocation_request_admin_message=@msg
                WHERE ID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@lid", reqLecturerId);
                cmd.Parameters.AddWithValue("@msg", msg);
                cmd.Parameters.AddWithValue("@id", programmeCourseId);
                cmd.ExecuteNonQuery();
            }
        }
        else if (d == "Rejected")
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                UPDATE acad_programmecourses
                SET allocation_request_status='No',
                    allocation_request_admin_status='Rejected',
                    allocation_request_admin_message=@msg
                WHERE ID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@msg", msg);
                cmd.Parameters.AddWithValue("@id", programmeCourseId);
                cmd.ExecuteNonQuery();
            }
        }
        else
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                UPDATE acad_programmecourses
                SET allocation_request_status='No',
                    allocation_request_admin_status='Pending',
                    allocation_request_admin_message=@msg
                WHERE ID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@msg", msg);
                cmd.Parameters.AddWithValue("@id", programmeCourseId);
                cmd.ExecuteNonQuery();
            }
        }

        resp.Success = true;
        resp.Message = "Request updated: " + d + ".";
        return resp;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DecisionResponse ProcessRequestDecision(int programmeCourseId, string decision, string adminMessage)
    {
        DecisionResponse resp = new DecisionResponse { Success = false, Message = "Invalid request." };
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                EnsureAllocationRequestColumns(conn);
                return ApplyDecision(conn, programmeCourseId, decision, adminMessage);
            }
        }
        catch (Exception ex)
        {
            resp.Message = "Request decision failed: " + ex.Message;
            return resp;
        }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DecisionResponse ProcessBatchRequestDecision(List<int> programmeCourseIds, string decision, string adminMessage)
    {
        DecisionResponse resp = new DecisionResponse { Success = false, Message = "Invalid batch request." };
        try
        {
            if (programmeCourseIds == null || programmeCourseIds.Count == 0)
            {
                resp.Message = "No rows selected.";
                return resp;
            }

            HashSet<int> ids = new HashSet<int>();
            foreach (int id in programmeCourseIds)
                if (id > 0) ids.Add(id);

            if (ids.Count == 0)
            {
                resp.Message = "No valid rows selected.";
                return resp;
            }

            int successCount = 0;
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                EnsureAllocationRequestColumns(conn);

                foreach (int id in ids)
                {
                    DecisionResponse one = ApplyDecision(conn, id, decision, adminMessage);
                    if (one.Success) successCount++;
                }
            }

            resp.Success = successCount > 0;
            resp.Message = successCount + " of " + ids.Count + " request(s) updated.";
            return resp;
        }
        catch (Exception ex)
        {
            resp.Message = "Batch decision failed: " + ex.Message;
            return resp;
        }
    }
}
