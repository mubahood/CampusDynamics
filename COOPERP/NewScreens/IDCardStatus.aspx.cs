using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_IDCardStatus : System.Web.UI.Page
{
    private string MainConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static bool _schemaChecked = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Ensure DB columns exist (runs once per app lifetime)
        if (!_schemaChecked)
        {
            EnsureSchema();
            _schemaChecked = true;
        }

        // AJAX handlers
        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetNoStore();
            HandleAjax(ajax);
            Response.End();
            return;
        }

        if (!IsPostBack)
        {
            LoadProgrammes();
            LoadData();
        }
    }

    /// <summary>Auto-creates id_card_status / id_card_checked_at columns if missing.</summary>
    private void EnsureSchema()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                // Check if column exists
                bool exists = false;
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_student' AND COLUMN_NAME='id_card_status'", conn))
                {
                    exists = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                }
                if (!exists)
                {
                    using (MySqlCommand alt = new MySqlCommand(
                        "ALTER TABLE acad_student " +
                        "ADD COLUMN id_card_status VARCHAR(30) DEFAULT NULL, " +
                        "ADD COLUMN id_card_checked_at DATETIME DEFAULT NULL", conn))
                    {
                        alt.ExecuteNonQuery();
                    }
                    // Best-effort index
                    try
                    {
                        using (MySqlCommand idx = new MySqlCommand(
                            "CREATE INDEX idx_student_card_status ON acad_student (id_card_status)", conn))
                        {
                            idx.ExecuteNonQuery();
                        }
                    }
                    catch { }
                }
            }
        }
        catch { /* If schema check itself fails, let the real query surface the error */ }
    }

    // ================================================================
    //  AJAX
    // ================================================================
    private void HandleAjax(string action)
    {
        if (action == "check")
        {
            AjaxCheckOne();
        }
        else if (action == "syncall")
        {
            AjaxSyncAll();
        }
        else
        {
            Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}");
        }
    }

    private void AjaxCheckOne()
    {
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"ok\":false,\"error\":\"Missing regno.\"}");
            return;
        }

        using (MySqlConnection conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            OmniPassHelper.CardStatus result = OmniPassHelper.GetStatus(regno, conn, true);
            string checkedAt = result.CheckedAt.HasValue ? result.CheckedAt.Value.ToString("dd/MM/yyyy HH:mm") : "-";
            Response.Write(string.Format(
                "{{\"ok\":true,\"status\":\"{0}\",\"label\":\"{1}\",\"css\":\"{2}\",\"message\":\"{3}\",\"checked_at\":\"{4}\"}}",
                JsEsc(result.Status), JsEsc(result.DisplayLabel), JsEsc(result.CssClass),
                JsEsc(result.Message ?? ""), JsEsc(checkedAt)));
        }
    }

    private void AjaxSyncAll()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                int updated = OmniPassHelper.BatchSync(conn, OmniPassHelper.StaleHours);
                if (updated >= 0)
                    Response.Write(string.Format("{{\"ok\":true,\"updated\":{0}}}", updated));
                else
                    Response.Write("{\"ok\":false,\"error\":\"Failed to fetch OmniPass card list.\"}");
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
    }

    // ================================================================
    //  Filters + Data
    // ================================================================
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("All Programmes", ""));
        using (MySqlConnection conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
            {
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        ddlProgramme.Items.Add(new ListItem(
                            rdr["progname"].ToString(), rdr["progcode"].ToString()));
                    }
                }
            }
        }
    }

    protected void btnApplyFilter_Click(object sender, EventArgs e)
    {
        LoadData();
    }

    private void LoadData()
    {
        int pageSize = 50;
        int ps;
        if (int.TryParse(ddlPageSize.SelectedValue, out ps)) pageSize = ps;
        int pageIndex = 0;
        int pi;
        if (int.TryParse(hfPageIndex.Value, out pi) && pi >= 0) pageIndex = pi;

        List<MySqlParameter> parms = new List<MySqlParameter>();
        StringBuilder where = new StringBuilder("WHERE UPPER(COALESCE(s.new_status,''))='ACTIVE'");

        string statusFilter = ddlStatus.SelectedValue;
        if (statusFilter == "__NULL")
        {
            where.Append(" AND s.id_card_status IS NULL");
        }
        else if (!string.IsNullOrEmpty(statusFilter))
        {
            where.Append(" AND s.id_card_status=@st");
            parms.Add(new MySqlParameter("@st", statusFilter));
        }

        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            where.Append(" AND s.progid=@prog");
            parms.Add(new MySqlParameter("@prog", ddlProgramme.SelectedValue));
        }

        string search = txtSearch.Text.Trim();
        if (!string.IsNullOrEmpty(search))
        {
            where.Append(" AND (s.regno LIKE @q OR CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')) LIKE @q)");
            parms.Add(new MySqlParameter("@q", "%" + search + "%"));
        }

        long totalRows = 0;
        DataTable dt = new DataTable();

        using (MySqlConnection conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();

            // Stats (all active students)
            LoadStats(conn);

            // Count
            string countSql = "SELECT COUNT(*) FROM acad_student s " + where.ToString();
            using (MySqlCommand cmd = new MySqlCommand(countSql, conn))
            {
                foreach (MySqlParameter p in parms) cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                object countResult = cmd.ExecuteScalar();
                totalRows = (countResult == null || countResult == DBNull.Value) ? 0 : Convert.ToInt64(countResult);
            }

            int totalPages = totalRows > 0 ? (int)Math.Ceiling((double)totalRows / pageSize) : 1;
            if (pageIndex >= totalPages) pageIndex = totalPages - 1;
            if (pageIndex < 0) pageIndex = 0;
            hfPageIndex.Value = pageIndex.ToString();

            // Data
            int rowStart = pageIndex * pageSize;
            string dataSql = string.Format(
                "SELECT s.regno, " +
                "TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name, " +
                "COALESCE(s.progid,'') AS progid, COALESCE(s.entryyear,'') AS entryyear, " +
                "s.id_card_status, s.id_card_checked_at " +
                "FROM acad_student s " +
                "{0} ORDER BY s.firstname ASC, s.othername ASC LIMIT {1},{2}",
                where.ToString(),
                rowStart, pageSize);

            using (MySqlCommand cmd = new MySqlCommand(dataSql, conn))
            {
                cmd.CommandTimeout = 30;
                foreach (MySqlParameter p in parms) cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            // Add row_num column computed in C#
            dt.Columns.Add("row_num", typeof(int));
            for (int i = 0; i < dt.Rows.Count; i++)
                dt.Rows[i]["row_num"] = rowStart + i + 1;

            rptStudents.DataSource = dt;
            rptStudents.DataBind();
            pnlEmpty.Visible = dt.Rows.Count == 0;

            // Record info
            long from = totalRows > 0 ? (long)(pageIndex * pageSize + 1) : 0;
            long to = Math.Min((long)(pageIndex + 1) * pageSize, totalRows);
            litRecordInfo.Text = string.Format("Showing {0:N0} - {1:N0} of {2:N0}", from, to, totalRows);

            // Pager
            StringBuilder pgHtml = new StringBuilder();
            for (int i = 0; i < totalPages && i < 20; i++)
            {
                string cls = i == pageIndex ? "idc-pager__btn idc-pager__btn--active" : "idc-pager__btn";
                pgHtml.AppendFormat("<button type=\"button\" class=\"{0}\" onclick=\"idcPage({1})\">{2}</button>", cls, i, i + 1);
            }
            litPager.Text = pgHtml.ToString();
        }
    }

    private void LoadStats(MySqlConnection conn)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT " +
            "  COUNT(*) AS total, " +
            "  COALESCE(SUM(CASE WHEN id_card_status='PRINTED' THEN 1 ELSE 0 END),0) AS printed, " +
            "  COALESCE(SUM(CASE WHEN id_card_status='NOT_PRINTED' THEN 1 ELSE 0 END),0) AS not_printed, " +
            "  COALESCE(SUM(CASE WHEN id_card_status='NOT_FOUND' THEN 1 ELSE 0 END),0) AS not_found, " +
            "  COALESCE(SUM(CASE WHEN id_card_status IS NULL THEN 1 ELSE 0 END),0) AS unchecked " +
            "FROM acad_student WHERE UPPER(COALESCE(new_status,''))='ACTIVE'", conn))
        {
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    litStatTotal.Text = SafeLong(rdr["total"]).ToString("N0");
                    litStatPrinted.Text = SafeLong(rdr["printed"]).ToString("N0");
                    litStatNotPrinted.Text = SafeLong(rdr["not_printed"]).ToString("N0");
                    litStatNotFound.Text = SafeLong(rdr["not_found"]).ToString("N0");
                    litStatUnchecked.Text = SafeLong(rdr["unchecked"]).ToString("N0");
                }
            }
        }
    }

    // ================================================================
    //  Helpers
    // ================================================================
    protected string GetStatusLabel(object val)
    {
        if (val == null || val == DBNull.Value) return "Unchecked";
        string s = val.ToString();
        switch (s)
        {
            case "PRINTED": return "Printed";
            case "NOT_PRINTED": return "Not Printed";
            case "NOT_FOUND": return "Not in System";
            case "ERROR": return "Check Failed";
            default: return "Unknown";
        }
    }

    protected string GetStatusCss(object val)
    {
        if (val == null || val == DBNull.Value) return "unknown";
        string s = val.ToString();
        switch (s)
        {
            case "PRINTED": return "printed";
            case "NOT_PRINTED": return "not-printed";
            case "NOT_FOUND": return "not-found";
            case "ERROR": return "error";
            default: return "unknown";
        }
    }

    protected string FormatCheckedAt(object val)
    {
        if (val == null || val == DBNull.Value) return "<span style='color:#ccc;'>Never</span>";
        DateTime dt = Convert.ToDateTime(val);
        double hours = (DateTime.Now - dt).TotalHours;
        string ago = "";
        if (hours < 1) ago = "just now";
        else if (hours < 24) ago = string.Format("{0:0}h ago", hours);
        else ago = string.Format("{0:0}d ago", hours / 24);
        return Server.HtmlEncode(dt.ToString("dd/MM/yyyy HH:mm")) + " <span style='color:#aaa;font-size:10px;'>(" + ago + ")</span>";
    }

    private string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }

    protected string SafeEncode(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return Server.HtmlEncode(val.ToString());
    }

    private long SafeLong(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        long result;
        return long.TryParse(val.ToString(), out result) ? result : 0;
    }
}
