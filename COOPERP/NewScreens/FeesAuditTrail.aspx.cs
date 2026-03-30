using System;
using System.Data;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_FeesAuditTrail : System.Web.UI.Page
{
    private string AcctConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }

    private string MainConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // HTML5 date inputs
        txtDateFrom.Attributes["type"] = "date";
        txtDateTo.Attributes["type"] = "date";

        LoadLookups();

        // Restore posted dropdown values (ViewState is disabled on SidebarMaster)
        RestorePostedValue(ddlAction);
        RestorePostedValue(ddlAcadYear);
        RestorePostedValue(ddlChangedBy);
        RestorePostedValue(ddlPageSize);

        LoadAuditData();
    }

    private void RestorePostedValue(DropDownList ddl)
    {
        string posted = Request.Form[ddl.UniqueID];
        if (!string.IsNullOrEmpty(posted))
        {
            ListItem item = ddl.Items.FindByValue(posted);
            if (item != null)
            {
                ddl.ClearSelection();
                item.Selected = true;
            }
        }
    }

    private void LoadLookups()
    {
        // Academic Years from audit records
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListItem("All Years", ""));
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT DISTINCT orig_acadyear FROM fin_changed_deleted_transactions WHERE orig_acadyear IS NOT NULL AND orig_acadyear != '' ORDER BY orig_acadyear DESC", conn))
            {
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string yr = rdr["orig_acadyear"].ToString();
                        ddlAcadYear.Items.Add(new ListItem(yr, yr));
                    }
                }
            }
        }

        // Changed By users
        ddlChangedBy.Items.Clear();
        ddlChangedBy.Items.Add(new ListItem("All Users", ""));
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT DISTINCT changed_by FROM fin_changed_deleted_transactions ORDER BY changed_by", conn))
            {
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string u = rdr["changed_by"].ToString();
                        ddlChangedBy.Items.Add(new ListItem(u, u));
                    }
                }
            }
        }
    }

    private void LoadAuditData()
    {
        StringBuilder where = new StringBuilder("WHERE 1=1");
        MySqlCommand cmd = new MySqlCommand();

        // Action filter
        if (!String.IsNullOrEmpty(ddlAction.SelectedValue))
        {
            where.Append(" AND a.action_type = @action");
            cmd.Parameters.AddWithValue("@action", ddlAction.SelectedValue);
        }

        // Academic year filter
        if (!String.IsNullOrEmpty(ddlAcadYear.SelectedValue))
        {
            where.Append(" AND a.orig_acadyear = @yr");
            cmd.Parameters.AddWithValue("@yr", ddlAcadYear.SelectedValue);
        }

        // Changed by filter
        if (!String.IsNullOrEmpty(ddlChangedBy.SelectedValue))
        {
            where.Append(" AND a.changed_by = @cb");
            cmd.Parameters.AddWithValue("@cb", ddlChangedBy.SelectedValue);
        }

        // Date range filters
        string dateFrom = txtDateFrom.Text.Trim();
        if (String.IsNullOrEmpty(dateFrom))
            dateFrom = Request.Form[txtDateFrom.UniqueID];
        if (!String.IsNullOrEmpty(dateFrom))
        {
            DateTime dtFrom;
            if (DateTime.TryParse(dateFrom, out dtFrom))
            {
                where.Append(" AND a.changed_at >= @dtFrom");
                cmd.Parameters.AddWithValue("@dtFrom", dtFrom.Date);
            }
        }

        string dateTo = txtDateTo.Text.Trim();
        if (String.IsNullOrEmpty(dateTo))
            dateTo = Request.Form[txtDateTo.UniqueID];
        if (!String.IsNullOrEmpty(dateTo))
        {
            DateTime dtTo;
            if (DateTime.TryParse(dateTo, out dtTo))
            {
                where.Append(" AND a.changed_at < @dtTo");
                cmd.Parameters.AddWithValue("@dtTo", dtTo.Date.AddDays(1));
            }
        }

        // Search
        string search = txtSearch.Text.Trim();
        if (!String.IsNullOrEmpty(search))
        {
            where.Append(" AND (a.orig_regno LIKE @q OR a.changed_by LIKE @q OR CAST(a.original_tid AS CHAR) LIKE @q OR CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')) LIKE @q OR a.orig_detail LIKE @q OR a.reason LIKE @q)");
            cmd.Parameters.AddWithValue("@q", "%" + search + "%");
        }

        int pageSize = 50;
        try { pageSize = Convert.ToInt32(ddlPageSize.SelectedValue); } catch { }

        // Stats query
        string statsSql = String.Format(
            @"SELECT 
                COUNT(*) AS total,
                SUM(CASE WHEN a.action_type='EDIT' THEN 1 ELSE 0 END) AS edit_cnt,
                SUM(CASE WHEN a.action_type='DELETE' THEN 1 ELSE 0 END) AS del_cnt,
                COUNT(DISTINCT a.changed_by) AS user_cnt
              FROM fin_changed_deleted_transactions a
              LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.orig_regno
              {0}", where.ToString());

        // Data query
        string dataSql = String.Format(
            @"SELECT a.AuditID, a.action_type, a.original_tid, a.orig_regno,
                     TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                     a.orig_trans_type, a.orig_item_code, a.orig_amount, a.orig_detail,
                     a.orig_trans_date, a.orig_acadyear, a.orig_semester, a.orig_post_status,
                     a.new_trans_type, a.new_item_code, a.new_amount, a.new_detail,
                     a.new_trans_date, a.new_acadyear, a.new_semester, a.new_post_status,
                     a.changed_by, a.changed_at, a.ip_address, a.reason,
                     COALESCE(bo.ItemName, CAST(a.orig_item_code AS CHAR)) AS orig_item_name,
                     COALESCE(bn.ItemName, CAST(a.new_item_code AS CHAR)) AS new_item_name
              FROM fin_changed_deleted_transactions a
              LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.orig_regno
              LEFT JOIN academicbillingitems bo ON bo.ItemCode = a.orig_item_code
              LEFT JOIN academicbillingitems bn ON bn.ItemCode = a.new_item_code
              {0}
              ORDER BY a.AuditID DESC", where.ToString());

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Stats
            cmd.Connection = conn;
            cmd.CommandText = statsSql;
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    long total = rdr["total"] != DBNull.Value ? Convert.ToInt64(rdr["total"]) : 0;
                    long editCnt = rdr["edit_cnt"] != DBNull.Value ? Convert.ToInt64(rdr["edit_cnt"]) : 0;
                    long delCnt = rdr["del_cnt"] != DBNull.Value ? Convert.ToInt64(rdr["del_cnt"]) : 0;
                    long userCnt = rdr["user_cnt"] != DBNull.Value ? Convert.ToInt64(rdr["user_cnt"]) : 0;

                    litTotalAudit.Text = total.ToString("N0");
                    litEditCount.Text = editCnt.ToString("N0");
                    litDeleteCount.Text = delCnt.ToString("N0");
                    litUserCount.Text = userCnt.ToString("N0");

                    lblRecordCount.Text = total.ToString("N0") + " records";
                }
            }

            // Grid
            MySqlCommand dataCmd = new MySqlCommand(dataSql, conn);
            foreach (MySqlParameter p in cmd.Parameters)
            {
                dataCmd.Parameters.AddWithValue(p.ParameterName, p.Value);
            }
            MySqlDataAdapter da = new MySqlDataAdapter(dataCmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvAudit.DataSource = dt;
            gvAudit.SettingsPager.PageSize = pageSize;
            gvAudit.DataBind();

            int totalRows = dt.Rows.Count;
            int totalPages = (int)Math.Ceiling((double)totalRows / pageSize);
            int currentPage = gvAudit.PageIndex + 1;
            lblGridFooter.Text = String.Format(
                "Showing page <strong>{0}</strong> of <strong>{1}</strong> &mdash; <strong>{2}</strong> total audit records ({3} per page)",
                currentPage, totalPages, totalRows.ToString("N0"), pageSize);
        }
    }

    // ====================================================================
    // Event Handlers
    // ====================================================================
    protected void ddlAction_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlChangedBy_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlPageSize_Changed(object sender, EventArgs e) { }
    protected void gvAudit_PageIndexChanged(object sender, EventArgs e) { }

    protected void btnSearch_Click(object sender, EventArgs e) { LoadAuditData(); }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ddlAction.SelectedIndex = 0;
        ddlAcadYear.SelectedIndex = 0;
        ddlChangedBy.SelectedIndex = 0;
        ddlPageSize.SelectedIndex = 0;
        txtSearch.Text = "";
        txtDateFrom.Text = "";
        txtDateTo.Text = "";
        LoadAuditData();
    }

    // ====================================================================
    // CSV Export
    // ====================================================================
    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        StringBuilder where = new StringBuilder("WHERE 1=1");
        MySqlCommand cmd = new MySqlCommand();

        if (!String.IsNullOrEmpty(ddlAction.SelectedValue))
        {
            where.Append(" AND a.action_type = @action");
            cmd.Parameters.AddWithValue("@action", ddlAction.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlAcadYear.SelectedValue))
        {
            where.Append(" AND a.orig_acadyear = @yr");
            cmd.Parameters.AddWithValue("@yr", ddlAcadYear.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlChangedBy.SelectedValue))
        {
            where.Append(" AND a.changed_by = @cb");
            cmd.Parameters.AddWithValue("@cb", ddlChangedBy.SelectedValue);
        }
        string search = txtSearch.Text.Trim();
        if (!String.IsNullOrEmpty(search))
        {
            where.Append(" AND (a.orig_regno LIKE @q OR a.changed_by LIKE @q OR CAST(a.original_tid AS CHAR) LIKE @q)");
            cmd.Parameters.AddWithValue("@q", "%" + search + "%");
        }

        string sql = String.Format(
            @"SELECT a.AuditID, a.action_type, a.original_tid, a.orig_regno,
                     TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                     a.orig_trans_type, a.orig_amount, a.orig_detail, a.orig_post_status,
                     a.orig_trans_date, a.orig_acadyear, a.orig_semester,
                     a.new_trans_type, a.new_amount, a.new_detail, a.new_post_status,
                     a.new_trans_date, a.new_acadyear, a.new_semester,
                     a.changed_by, a.changed_at, a.ip_address, a.reason
              FROM fin_changed_deleted_transactions a
              LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.orig_regno
              {0}
              ORDER BY a.AuditID DESC", where.ToString());

        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            cmd.Connection = conn;
            cmd.CommandText = sql;
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            da.Fill(dt);
        }

        Response.Clear();
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition", "attachment;filename=FeeAuditTrail_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("AuditID,Action,OriginalTID,RegNo,Student,OrigType,OrigAmount,OrigDetail,OrigStatus,OrigDate,OrigYear,OrigSem,NewType,NewAmount,NewDetail,NewStatus,NewDate,NewYear,NewSem,ChangedBy,ChangedAt,IP,Reason");
        foreach (DataRow row in dt.Rows)
        {
            sb.AppendFormat("{0},{1},{2},\"{3}\",\"{4}\",{5},{6},\"{7}\",{8},{9},{10},{11},{12},{13},\"{14}\",{15},{16},{17},{18},\"{19}\",{20},\"{21}\",\"{22}\"\r\n",
                row["AuditID"], row["action_type"], row["original_tid"],
                CsvSafe(row["orig_regno"]), CsvSafe(row["student_name"]),
                row["orig_trans_type"], row["orig_amount"],
                CsvSafe(row["orig_detail"]), row["orig_post_status"],
                row["orig_trans_date"], row["orig_acadyear"], row["orig_semester"],
                row["new_trans_type"] != DBNull.Value ? row["new_trans_type"] : "",
                row["new_amount"] != DBNull.Value ? row["new_amount"].ToString() : "",
                CsvSafe(row["new_detail"]),
                row["new_post_status"] != DBNull.Value ? row["new_post_status"] : "",
                row["new_trans_date"] != DBNull.Value ? row["new_trans_date"].ToString() : "",
                row["new_acadyear"] != DBNull.Value ? row["new_acadyear"] : "",
                row["new_semester"] != DBNull.Value ? row["new_semester"].ToString() : "",
                CsvSafe(row["changed_by"]), row["changed_at"],
                CsvSafe(row["ip_address"]), CsvSafe(row["reason"]));
        }
        Response.Write(sb.ToString());
        Response.End();
    }

    // ====================================================================
    // Template Helpers
    // ====================================================================
    protected string GetActionClass(object val)
    {
        string v = val != null ? val.ToString() : "";
        if (v == "EDIT") return "fa-badge--edit";
        if (v == "DELETE") return "fa-badge--delete";
        return "";
    }

    protected string FormatAmt(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        decimal d = Convert.ToDecimal(val);
        return "UGX " + d.ToString("N0");
    }

    protected string FormatAmountChange(object origAmt, object newAmt, object actionType)
    {
        string action = actionType != null ? actionType.ToString() : "";
        if (action == "DELETE")
            return "<span style='color:#dc3545;font-weight:600;'>REMOVED</span>";

        if (origAmt == null || origAmt == DBNull.Value || newAmt == null || newAmt == DBNull.Value)
            return "—";

        decimal orig = Convert.ToDecimal(origAmt);
        decimal newV = Convert.ToDecimal(newAmt);
        decimal diff = newV - orig;

        if (diff == 0)
            return "<span style='color:#888;'>No change</span>";
        else if (diff > 0)
            return "<span style='color:#16a34a;font-weight:600;'>+" + diff.ToString("N0") + "</span>";
        else
            return "<span style='color:#dc3545;font-weight:600;'>" + diff.ToString("N0") + "</span>";
    }

    protected string FormatDateTime(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        try { return Convert.ToDateTime(val).ToString("dd MMM yyyy HH:mm"); }
        catch { return val.ToString(); }
    }

    protected string FormatDateISO(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        try { return Convert.ToDateTime(val).ToString("yyyy-MM-dd"); }
        catch { return val.ToString(); }
    }

    protected string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private string CsvSafe(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString().Replace("\"", "\"\"");
    }

    private void ShowToast(string message, bool success)
    {
        pnlToast.Visible = true;
        divToast.Attributes["class"] = success ? "fs-toast fs-toast--success" : "fs-toast fs-toast--error";
        divToast.InnerHtml = Server.HtmlEncode(message);
    }
}
