using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Admin view of all retake registrations — original vs new marks, fee status, marks stage.
/// Read/monitor + CSV export. Data: campus_dynamics_portal.acad_retake_registrations.
/// </summary>
public partial class COOPERP_NewScreens_RetakeController : System.Web.UI.Page
{
    private string Conn { get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; } }
    private const string RR = "campus_dynamics_portal.acad_retake_registrations";
    private const string CR = "campus_dynamics_portal.acad_course_registration";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAcademicYears();
            ApplyQueryString();
            LoadStats();
            BindGrid();
        }
    }

    private void LoadAcademicYears()
    {
        ddlYear.Items.Clear();
        ddlYear.Items.Add(new ListItem("All Years", ""));
        try
        {
            using (var conn = new MySqlConnection(Conn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand("SELECT DISTINCT retake_acad_year FROM " + RR + " WHERE TRIM(IFNULL(retake_acad_year,''))<>'' ORDER BY retake_acad_year DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read()) ddlYear.Items.Add(new ListItem(rdr[0].ToString(), rdr[0].ToString()));
            }
        }
        catch { }
    }

    private void ApplyQueryString()
    {
        SetSel(ddlYear, Request.QueryString["ay"]);
        SetSel(ddlSem, Request.QueryString["sem"]);
        SetSel(ddlStatus, Request.QueryString["st"]);
        if (!string.IsNullOrEmpty(Request.QueryString["q"])) txtSearch.Text = Request.QueryString["q"];
    }
    private void SetSel(ListControl c, string v)
    {
        if (c == null || string.IsNullOrEmpty(v)) return;
        var it = c.Items.FindByValue(v);
        if (it != null) { c.ClearSelection(); it.Selected = true; }
    }

    private string BuildWhere(List<MySqlParameter> ps)
    {
        var sb = new StringBuilder(" WHERE 1=1");
        if (!string.IsNullOrEmpty(ddlYear.SelectedValue)) { sb.Append(" AND rr.retake_acad_year=@ay"); ps.Add(new MySqlParameter("@ay", ddlYear.SelectedValue)); }
        if (!string.IsNullOrEmpty(ddlSem.SelectedValue)) { sb.Append(" AND rr.retake_semester=@sem"); ps.Add(new MySqlParameter("@sem", SafeInt(ddlSem.SelectedValue, 0))); }
        if (!string.IsNullOrEmpty(ddlStatus.SelectedValue)) { sb.Append(" AND rr.status=@st"); ps.Add(new MySqlParameter("@st", ddlStatus.SelectedValue)); }
        string q = (txtSearch.Text ?? "").Trim();
        if (!string.IsNullOrEmpty(q))
        {
            sb.Append(" AND (rr.regno LIKE @q OR rr.courseID LIKE @q OR rr.course_name LIKE @q OR TRIM(CONCAT_WS(' ',s.firstname,s.othername)) LIKE @q)");
            ps.Add(new MySqlParameter("@q", "%" + q + "%"));
        }
        return sb.ToString();
    }

    private void LoadStats()
    {
        var ps = new List<MySqlParameter>();
        string where = BuildWhere(ps);
        string sql = @"SELECT COUNT(*) total,
            SUM(rr.status='COMPLETED') completed,
            SUM(rr.status NOT IN ('COMPLETED','CANCELLED')) active,
            SUM(rr.fee_billed='Yes') billed,
            COALESCE(SUM(CASE WHEN rr.fee_billed='Yes' THEN rr.retake_fee ELSE 0 END),0) fee
            FROM " + RR + @" rr LEFT JOIN acad_student s ON TRIM(s.regno)=TRIM(rr.regno)" + where;
        try
        {
            using (var conn = new MySqlConnection(Conn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    foreach (var p in ps) cmd.Parameters.Add(p);
                    using (var rdr = cmd.ExecuteReader())
                        if (rdr.Read())
                        {
                            litTotal.Text = N(rdr["total"]);
                            litActive.Text = N(rdr["active"]);
                            litCompleted.Text = N(rdr["completed"]);
                            litBilled.Text = N(rdr["billed"]);
                            litFee.Text = "UGX " + N(rdr["fee"]);
                        }
                }
            }
        }
        catch { }
    }

    private void BindGrid()
    {
        var ps = new List<MySqlParameter>();
        string where = BuildWhere(ps);
        string sql = @"
            SELECT rr.ID, rr.regno,
                   TRIM(CONCAT_WS(' ', NULLIF(s.firstname,''), NULLIF(s.othername,''))) AS name,
                   rr.courseID, rr.course_name, rr.prog_id, rr.attempt_no,
                   rr.orig_acad_year, rr.orig_semester, rr.orig_grade, rr.orig_total,
                   rr.retake_acad_year, rr.retake_semester, rr.fee_billed, rr.status,
                   rr.new_grade, rr.new_total, rr.registered_by,
                   DATE_FORMAT(rr.registered_at,'%d %b %Y') AS reg_date,
                   COALESCE(cr.mark_stage,'NOT_ENTERED') AS stage
            FROM " + RR + @" rr
            LEFT JOIN acad_student s ON TRIM(s.regno)=TRIM(rr.regno)
            LEFT JOIN " + CR + @" cr ON cr.ID=rr.course_reg_id" + where + @"
            ORDER BY rr.registered_at DESC, rr.ID DESC
            LIMIT 1000";
        try
        {
            using (var conn = new MySqlConnection(Conn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    foreach (var p in ps) cmd.Parameters.Add(p);
                    using (var da = new MySqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        rpt.DataSource = dt;
                        rpt.DataBind();
                        pnlEmpty.Visible = dt.Rows.Count == 0;
                        litCount.Text = dt.Rows.Count.ToString("N0") + (dt.Rows.Count == 1000 ? "+ (capped)" : "") + " retake(s)";
                    }
                }
            }
        }
        catch (Exception ex) { litCount.Text = "Error: " + Server.HtmlEncode(ex.Message); }
    }

    protected void btnFilter_Click(object sender, EventArgs e) { RedirectWithFilters(); }
    protected void btnReset_Click(object sender, EventArgs e) { Response.Redirect("RetakeController.aspx"); }

    private void RedirectWithFilters()
    {
        var q = HttpUtility.ParseQueryString(string.Empty);
        if (!string.IsNullOrEmpty(ddlYear.SelectedValue)) q["ay"] = ddlYear.SelectedValue;
        if (!string.IsNullOrEmpty(ddlSem.SelectedValue)) q["sem"] = ddlSem.SelectedValue;
        if (!string.IsNullOrEmpty(ddlStatus.SelectedValue)) q["st"] = ddlStatus.SelectedValue;
        if (!string.IsNullOrEmpty(txtSearch.Text.Trim())) q["q"] = txtSearch.Text.Trim();
        string s = q.ToString();
        Response.Redirect("RetakeController.aspx" + (string.IsNullOrEmpty(s) ? "" : "?" + s));
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        var ps = new List<MySqlParameter>();
        string where = BuildWhere(ps);
        string sql = @"
            SELECT rr.regno, TRIM(CONCAT_WS(' ', NULLIF(s.firstname,''), NULLIF(s.othername,''))) AS name,
                   rr.courseID, rr.course_name, rr.prog_id, rr.attempt_no,
                   rr.orig_acad_year, rr.orig_semester, rr.orig_total, rr.orig_grade,
                   rr.retake_acad_year, rr.retake_semester, rr.fee_billed, rr.retake_fee, rr.status,
                   rr.new_total, rr.new_grade, COALESCE(cr.mark_stage,'NOT_ENTERED') AS stage,
                   rr.registered_by, DATE_FORMAT(rr.registered_at,'%Y-%m-%d') AS reg_date
            FROM " + RR + @" rr
            LEFT JOIN acad_student s ON TRIM(s.regno)=TRIM(rr.regno)
            LEFT JOIN " + CR + @" cr ON cr.ID=rr.course_reg_id" + where + " ORDER BY rr.registered_at DESC";
        try
        {
            using (var conn = new MySqlConnection(Conn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    foreach (var p in ps) cmd.Parameters.Add(p);
                    using (var da = new MySqlDataAdapter(cmd))
                    {
                        var dt = new DataTable(); da.Fill(dt);
                        var csv = new StringBuilder();
                        csv.AppendLine("Reg No,Student,Course Code,Course Name,Programme,Attempt,Orig Year,Orig Sem,Orig Total,Orig Grade,Retake Year,Retake Sem,Fee Billed,Retake Fee,Status,New Total,New Grade,Marks Stage,Registered By,Registered On");
                        foreach (DataRow r in dt.Rows)
                            csv.AppendLine(string.Join(",",
                                C(r["regno"]), C(r["name"]), C(r["courseID"]), C(r["course_name"]), C(r["prog_id"]), C(r["attempt_no"]),
                                C(r["orig_acad_year"]), C(r["orig_semester"]), C(r["orig_total"]), C(r["orig_grade"]),
                                C(r["retake_acad_year"]), C(r["retake_semester"]), C(r["fee_billed"]), C(r["retake_fee"]), C(r["status"]),
                                C(r["new_total"]), C(r["new_grade"]), C(r["stage"]), C(r["registered_by"]), C(r["reg_date"])));
                        Response.Clear();
                        Response.ContentType = "text/csv";
                        Response.AddHeader("Content-Disposition", "attachment; filename=retakes.csv");
                        Response.Write(csv.ToString());
                        Response.End();
                    }
                }
            }
        }
        catch (Exception ex) { litCount.Text = "Export failed: " + Server.HtmlEncode(ex.Message); }
    }

    // template helpers
    protected string StageBadge(object stage)
    {
        string s = (stage == null ? "" : stage.ToString()).Trim().ToUpperInvariant();
        string color = "#475569", bg = "#eef2f7";
        if (s == "PUBLISHED") { color = "#15803d"; bg = "#e6f4ea"; }
        else if (s == "APPROVED") { color = "#1d4ed8"; bg = "#e8f0fe"; }
        else if (s == "CAPTURED") { color = "#b45309"; bg = "#fff3e0"; }
        else if (s == "ENTERED") { color = "#7c3aed"; bg = "#f3e8ff"; }
        return string.Format("<span style='display:inline-block;padding:2px 9px;font-size:9.5px;font-weight:700;border-radius:10px;color:{0};background:{1};'>{2}</span>", color, bg, Server.HtmlEncode(s.Replace("_", " ")));
    }
    protected string StatusBadge(object status)
    {
        string s = (status == null ? "" : status.ToString()).Trim().ToUpperInvariant();
        string color = "#b45309", bg = "#fff3cd";
        if (s == "COMPLETED") { color = "#15803d"; bg = "#e6f4ea"; }
        else if (s == "CANCELLED") { color = "#b91c1c"; bg = "#fde8e8"; }
        return string.Format("<span style='display:inline-block;padding:2px 9px;font-size:9.5px;font-weight:700;border-radius:10px;color:{0};background:{1};'>{2}</span>", color, bg, Server.HtmlEncode(s));
    }

    private static int SafeInt(string v, int d) { int r; return int.TryParse(v, out r) ? r : d; }
    private static string N(object v) { if (v == null || v == DBNull.Value) return "0"; long n; return long.TryParse(v.ToString(), out n) ? n.ToString("N0") : v.ToString(); }
    private string C(object v)
    {
        string s = v == null || v == DBNull.Value ? "" : v.ToString();
        if (s.Contains(",") || s.Contains("\"") || s.Contains("\n")) return "\"" + s.Replace("\"", "\"\"") + "\"";
        return s;
    }
}
