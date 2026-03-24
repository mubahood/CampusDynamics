using System;
using System.Data;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_FeesTransactions : System.Web.UI.Page
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
        if (!IsPostBack)
        {
            LoadLookups();

            // Default to current academic year
            string curYear = AcademicYearHelper.GetCurrentAcademicYear();
            if (ddlAcadYear.Items.FindByValue(curYear) != null)
                ddlAcadYear.SelectedValue = curYear;

            LoadTransactions();
        }
    }

    private void LoadLookups()
    {
        // Academic Years
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListItem("All Years", ""));
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT DISTINCT acadyear FROM fin_studentfeestracking ORDER BY acadyear DESC", conn))
            {
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string yr = rdr["acadyear"].ToString();
                        if (!String.IsNullOrEmpty(yr))
                            ddlAcadYear.Items.Add(new ListItem(yr, yr));
                    }
                }
            }
        }

        // Billing Items
        ddlBillItem.Items.Clear();
        ddlBillItem.Items.Add(new ListItem("All Items", ""));
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT ItemCode, ItemName FROM academicbillingitems ORDER BY ItemName", conn))
            {
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        ddlBillItem.Items.Add(new ListItem(rdr["ItemName"].ToString(), rdr["ItemCode"].ToString()));
                    }
                }
            }
        }
    }

    private void LoadTransactions()
    {
        // Build WHERE
        StringBuilder where = new StringBuilder("WHERE 1=1");
        MySqlCommand cmd = new MySqlCommand();

        if (!String.IsNullOrEmpty(ddlAcadYear.SelectedValue))
        {
            where.Append(" AND t.acadyear = @yr");
            cmd.Parameters.AddWithValue("@yr", ddlAcadYear.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlSemester.SelectedValue))
        {
            where.Append(" AND t.semester = @sem");
            cmd.Parameters.AddWithValue("@sem", ddlSemester.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlTransType.SelectedValue))
        {
            where.Append(" AND t.trans_type = @tt");
            cmd.Parameters.AddWithValue("@tt", ddlTransType.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlBillItem.SelectedValue))
        {
            where.Append(" AND t.item_code = @ic");
            cmd.Parameters.AddWithValue("@ic", ddlBillItem.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlPostStatus.SelectedValue))
        {
            where.Append(" AND t.post_status = @ps");
            cmd.Parameters.AddWithValue("@ps", ddlPostStatus.SelectedValue);
        }
        string search = txtSearch.Text.Trim();
        if (!String.IsNullOrEmpty(search))
        {
            where.Append(" AND (t.regno LIKE @q OR CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')) LIKE @q OR t.detail LIKE @q)");
            cmd.Parameters.AddWithValue("@q", "%" + search + "%");
        }

        int pageSize = 50;
        try { pageSize = Convert.ToInt32(ddlPageSize.SelectedValue); } catch { }

        // Stats query
        string statsSql = String.Format(
            @"SELECT 
                COUNT(*) AS total_tx,
                SUM(CASE WHEN t.trans_type='Bill' THEN 1 ELSE 0 END) AS bill_cnt,
                SUM(CASE WHEN t.trans_type='Payment' THEN 1 ELSE 0 END) AS pay_cnt,
                SUM(CASE WHEN t.trans_type='Bill' THEN t.amount ELSE 0 END) AS bill_amt,
                SUM(CASE WHEN t.trans_type='Payment' THEN t.amount ELSE 0 END) AS pay_amt
              FROM fin_studentfeestracking t
              LEFT JOIN campus_dynamics.acad_student s ON s.regno = t.regno
              {0}", where.ToString());

        // Data query
        string dataSql = String.Format(
            @"SELECT t.TID, t.regno,
                     TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                     t.trans_type, t.amount, t.detail, t.post_status, t.trans_date,
                     t.acadyear, t.semester, t.item_code,
                     COALESCE(b.ItemName, t.item_code) AS item_name
              FROM fin_studentfeestracking t
              LEFT JOIN campus_dynamics.acad_student s ON s.regno = t.regno
              LEFT JOIN academicbillingitems b ON b.ItemCode = t.item_code
              {0}
              ORDER BY t.TID DESC
              LIMIT {1}", where.ToString(), pageSize);

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
                    long totalTx = rdr["total_tx"] != DBNull.Value ? Convert.ToInt64(rdr["total_tx"]) : 0;
                    long billCnt = rdr["bill_cnt"] != DBNull.Value ? Convert.ToInt64(rdr["bill_cnt"]) : 0;
                    long payCnt = rdr["pay_cnt"] != DBNull.Value ? Convert.ToInt64(rdr["pay_cnt"]) : 0;
                    decimal billAmt = rdr["bill_amt"] != DBNull.Value ? Convert.ToDecimal(rdr["bill_amt"]) : 0;
                    decimal payAmt = rdr["pay_amt"] != DBNull.Value ? Convert.ToDecimal(rdr["pay_amt"]) : 0;

                    litTotalTx.Text = totalTx.ToString("N0");
                    litBillTx.Text = billCnt.ToString("N0");
                    litPayTx.Text = payCnt.ToString("N0");
                    litBillAmt.Text = FormatCurrency(billAmt);
                    litPayAmt.Text = FormatCurrency(payAmt);

                    lblRecordCount.Text = totalTx.ToString("N0") + " records";
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

            gvTransactions.DataSource = dt;
            gvTransactions.SettingsPager.PageSize = pageSize;
            gvTransactions.DataBind();

            lblGridFooter.Text = String.Format("Showing <strong>{0}</strong> transactions (limited to {1} per page)", dt.Rows.Count, pageSize);
        }

        // Context badge
        string ctx = "";
        if (!String.IsNullOrEmpty(ddlAcadYear.SelectedValue))
            ctx = ddlAcadYear.SelectedValue;
        if (!String.IsNullOrEmpty(ddlSemester.SelectedValue))
            ctx += " Sem " + ddlSemester.SelectedValue;
        if (!String.IsNullOrEmpty(ctx))
            litAcadContext.Text = "<span class='ft-card__meta'>" + Server.HtmlEncode(ctx.Trim()) + "</span>";
        else
            litAcadContext.Text = "";
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e) { LoadTransactions(); }
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e) { LoadTransactions(); }
    protected void ddlTransType_SelectedIndexChanged(object sender, EventArgs e) { LoadTransactions(); }
    protected void ddlBillItem_SelectedIndexChanged(object sender, EventArgs e) { LoadTransactions(); }
    protected void ddlPostStatus_SelectedIndexChanged(object sender, EventArgs e) { LoadTransactions(); }
    protected void ddlPageSize_Changed(object sender, EventArgs e) { LoadTransactions(); }

    protected void btnSearch_Click(object sender, EventArgs e) { LoadTransactions(); }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ddlAcadYear.SelectedIndex = 0;
        ddlSemester.SelectedIndex = 0;
        ddlTransType.SelectedIndex = 0;
        ddlBillItem.SelectedIndex = 0;
        ddlPostStatus.SelectedIndex = 0;
        ddlPageSize.SelectedIndex = 0;
        txtSearch.Text = "";
        LoadTransactions();
    }

    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        // Build WHERE (same as LoadTransactions)
        StringBuilder where = new StringBuilder("WHERE 1=1");
        MySqlCommand cmd = new MySqlCommand();

        if (!String.IsNullOrEmpty(ddlAcadYear.SelectedValue))
        {
            where.Append(" AND t.acadyear = @yr");
            cmd.Parameters.AddWithValue("@yr", ddlAcadYear.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlSemester.SelectedValue))
        {
            where.Append(" AND t.semester = @sem");
            cmd.Parameters.AddWithValue("@sem", ddlSemester.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlTransType.SelectedValue))
        {
            where.Append(" AND t.trans_type = @tt");
            cmd.Parameters.AddWithValue("@tt", ddlTransType.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlBillItem.SelectedValue))
        {
            where.Append(" AND t.item_code = @ic");
            cmd.Parameters.AddWithValue("@ic", ddlBillItem.SelectedValue);
        }
        if (!String.IsNullOrEmpty(ddlPostStatus.SelectedValue))
        {
            where.Append(" AND t.post_status = @ps");
            cmd.Parameters.AddWithValue("@ps", ddlPostStatus.SelectedValue);
        }
        string search = txtSearch.Text.Trim();
        if (!String.IsNullOrEmpty(search))
        {
            where.Append(" AND (t.regno LIKE @q OR CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')) LIKE @q OR t.detail LIKE @q)");
            cmd.Parameters.AddWithValue("@q", "%" + search + "%");
        }

        string sql = String.Format(
            @"SELECT t.TID, t.regno,
                     TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                     t.trans_type, COALESCE(b.ItemName, t.item_code) AS item_name,
                     t.amount, t.detail, t.post_status, t.trans_date, t.acadyear, t.semester
              FROM fin_studentfeestracking t
              LEFT JOIN campus_dynamics.acad_student s ON s.regno = t.regno
              LEFT JOIN academicbillingitems b ON b.ItemCode = t.item_code
              {0}
              ORDER BY t.TID DESC", where.ToString());

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
        Response.AddHeader("Content-Disposition", "attachment;filename=FeeTransactions_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("TID,RegNo,Student,Type,Billing Item,Amount,Description,Status,Date,Year,Semester");
        foreach (DataRow row in dt.Rows)
        {
            sb.AppendFormat("{0},\"{1}\",\"{2}\",{3},\"{4}\",{5},\"{6}\",{7},{8},{9},{10}\r\n",
                row["TID"], CsvSafe(row["regno"]), CsvSafe(row["student_name"]),
                row["trans_type"], CsvSafe(row["item_name"]), row["amount"],
                CsvSafe(row["detail"]), row["post_status"], row["trans_date"],
                row["acadyear"], row["semester"]);
        }
        Response.Write(sb.ToString());
        Response.End();
    }

    // Helpers
    protected string GetTypeClass(object val)
    {
        string v = val != null ? val.ToString() : "";
        if (v == "Bill") return "ft-badge--bill";
        if (v == "Payment") return "ft-badge--pay";
        return "";
    }

    protected string GetStatusClass(object val)
    {
        string v = val != null ? val.ToString() : "";
        if (v == "Posted") return "ft-badge--posted";
        return "ft-badge--pending";
    }

    protected string FormatAmt(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        decimal d = Convert.ToDecimal(val);
        return "UGX " + d.ToString("N0");
    }

    private string FormatCurrency(decimal val)
    {
        if (val >= 1000000000m)
            return String.Format("UGX {0:N1}B", val / 1000000000m);
        if (val >= 1000000m)
            return String.Format("UGX {0:N1}M", val / 1000000m);
        return String.Format("UGX {0:N0}", val);
    }

    private string CsvSafe(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString().Replace("\"", "\"\"");
    }
}
