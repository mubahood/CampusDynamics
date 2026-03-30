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
        // AJAX student lookup — returns JSON, no page rendering
        string ajaxAction = Request.QueryString["ajax"];
        if (ajaxAction == "lookup" || ajaxAction == "search")
        {
            HandleStudentLookup();
            return;
        }

        LoadLookups();

        // Set HTML5 input types (.NET 4 doesn't have TextMode="Number"/"Date")
        txtTxAmount.Attributes["type"] = "number";
        txtTxAmount.Attributes["min"] = "1";
        txtTxAmount.Attributes["step"] = "1";
        txtTxDate.Attributes["type"] = "date";

        // Edit modal input types
        txtEditAmount.Attributes["type"] = "number";
        txtEditAmount.Attributes["min"] = "1";
        txtEditAmount.Attributes["step"] = "1";
        txtEditDate.Attributes["type"] = "date";

        // Restore posted dropdown values
        RestorePostedValue(ddlAcadYear);
        RestorePostedValue(ddlSemester);
        RestorePostedValue(ddlTransType);
        RestorePostedValue(ddlBillItem);
        RestorePostedValue(ddlPostStatus);
        RestorePostedValue(ddlStudStatus);
        RestorePostedValue(ddlPageSize);

        // Restore edit modal dropdown values
        RestorePostedValue(ddlEditTransType);
        RestorePostedValue(ddlEditBillItem);
        RestorePostedValue(ddlEditAcadYear);
        RestorePostedValue(ddlEditSemester);
        RestorePostedValue(ddlEditPostStatus);

        if (!IsPostBack)
        {
            // If a specific TID is requested via querystring, clear the year filter
            // so the record always shows regardless of academic year.
            string tidParam = Request.QueryString["tid"];
            int tidParamVal = 0;
            if (!string.IsNullOrEmpty(tidParam) && int.TryParse(tidParam.Trim(), out tidParamVal) && tidParamVal > 0)
            {
                ddlAcadYear.ClearSelection();
                if (ddlAcadYear.Items.FindByValue("") != null)
                    ddlAcadYear.SelectedValue = "";
            }
            else
            {
                // Default to current academic year
                string curYear = AcademicYearHelper.GetCurrentAcademicYear();
                if (ddlAcadYear.Items.FindByValue(curYear) != null)
                    ddlAcadYear.SelectedValue = curYear;
            }
        }

        LoadTransactions();
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

        // Billing Items (filter)
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

        // === Modal form dropdowns ===

        // Billing Items (modal — with placeholder)
        ddlTxBillItem.Items.Clear();
        ddlTxBillItem.Items.Add(new ListItem("-- Select Item --", ""));
        foreach (ListItem li in ddlBillItem.Items)
        {
            if (!String.IsNullOrEmpty(li.Value))
                ddlTxBillItem.Items.Add(new ListItem(li.Text, li.Value));
        }

        // Academic Years (modal)
        ddlTxAcadYear.Items.Clear();
        ddlTxAcadYear.Items.Add(new ListItem("-- Select Year --", ""));
        foreach (ListItem li in ddlAcadYear.Items)
        {
            if (!String.IsNullOrEmpty(li.Value))
                ddlTxAcadYear.Items.Add(new ListItem(li.Text, li.Value));
        }

        // === Edit modal form dropdowns ===

        // Billing Items (edit modal)
        ddlEditBillItem.Items.Clear();
        ddlEditBillItem.Items.Add(new ListItem("-- Select Item --", ""));
        foreach (ListItem li in ddlBillItem.Items)
        {
            if (!String.IsNullOrEmpty(li.Value))
                ddlEditBillItem.Items.Add(new ListItem(li.Text, li.Value));
        }

        // Academic Years (edit modal)
        ddlEditAcadYear.Items.Clear();
        ddlEditAcadYear.Items.Add(new ListItem("-- Select Year --", ""));
        foreach (ListItem li in ddlAcadYear.Items)
        {
            if (!String.IsNullOrEmpty(li.Value))
                ddlEditAcadYear.Items.Add(new ListItem(li.Text, li.Value));
        }

        // Default modal academic year to current if not postback
        if (!IsPostBack)
        {
            string curYear = AcademicYearHelper.GetCurrentAcademicYear();
            if (ddlTxAcadYear.Items.FindByValue(curYear) != null)
                ddlTxAcadYear.SelectedValue = curYear;

            int curSem = AcademicYearHelper.GetCurrentSemester();
            if (ddlTxSemester.Items.FindByValue(curSem.ToString()) != null)
                ddlTxSemester.SelectedValue = curSem.ToString();
        }
    }

    private void LoadTransactions()
    {
        // Build WHERE
        StringBuilder where = new StringBuilder("WHERE 1=1");
        MySqlCommand cmd = new MySqlCommand();

        // ------------------------------------------------------------------
        // ?tid= querystring: filter to a single transaction
        // ------------------------------------------------------------------
        string tidParam = Request.QueryString["tid"];
        int tidParamVal = 0;
        bool isTidFilter = !string.IsNullOrEmpty(tidParam)
                           && int.TryParse(tidParam.Trim(), out tidParamVal)
                           && tidParamVal > 0;

        if (isTidFilter)
        {
            where.Append(" AND t.TID = @tidFilter");
            cmd.Parameters.AddWithValue("@tidFilter", tidParamVal);
        }

        // Always LEFT JOIN — every transaction shows regardless of student enrolment status.
        // If the user explicitly picks a student status in the filter dropdown, apply it as
        // a WHERE condition (not as an INNER JOIN) so unmatched rows are still visible.
        string studentJoin = "LEFT JOIN campus_dynamics.acad_student s ON s.regno = t.regno";

        string studStatus = ddlStudStatus.SelectedValue;
        if (!string.IsNullOrEmpty(studStatus))
        {
            where.Append(" AND UPPER(COALESCE(s.new_status,'')) = UPPER(@studStatus)");
            cmd.Parameters.AddWithValue("@studStatus", studStatus);
        }

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

        // -----------------------------------------------------------------------
        // Server-side paging
        // -----------------------------------------------------------------------
        int pageSize = 50;
        try { pageSize = Convert.ToInt32(ddlPageSize.SelectedValue); } catch { }

        // Determine page index: reset on filter/search changes, preserve on explicit pager clicks
        string eventTarget = Request.Form["__EVENTTARGET"] ?? "";
        bool isPageNavClick = Request.Form[btnGoToPage.UniqueID] != null;
        bool isFilterDropdown =
            eventTarget == ddlAcadYear.UniqueID   || eventTarget == ddlSemester.UniqueID  ||
            eventTarget == ddlTransType.UniqueID  || eventTarget == ddlBillItem.UniqueID  ||
            eventTarget == ddlPostStatus.UniqueID || eventTarget == ddlStudStatus.UniqueID ||
            eventTarget == ddlPageSize.UniqueID;
        bool isSearchOrReset =
            Request.Form[btnSearch.UniqueID] != null || Request.Form[btnReset.UniqueID] != null;

        int pageIndex = 0;
        if (isPageNavClick)
        {
            int.TryParse(hfPageIndex.Value, out pageIndex);
            if (pageIndex < 0) pageIndex = 0;
        }
        else if (isFilterDropdown || isSearchOrReset || !IsPostBack)
        {
            pageIndex = 0;
            hfPageIndex.Value = "0";
        }
        else
        {
            int.TryParse(hfPageIndex.Value, out pageIndex);
            if (pageIndex < 0) pageIndex = 0;
        }

        // Stats query (row count + totals in one pass)
        string statsSql = String.Format(
            @"SELECT 
                COUNT(*) AS total_tx,
                SUM(CASE WHEN t.trans_type='Bill' THEN 1 ELSE 0 END) AS bill_cnt,
                SUM(CASE WHEN t.trans_type='Payment' THEN 1 ELSE 0 END) AS pay_cnt,
                SUM(CASE WHEN t.trans_type='Bill' THEN t.amount ELSE 0 END) AS bill_amt,
                SUM(CASE WHEN t.trans_type='Payment' THEN t.amount ELSE 0 END) AS pay_amt
              FROM fin_studentfeestracking t
              {1}
              {0}", where.ToString(), studentJoin);

        // Data query — server-side paged with LIMIT/OFFSET
        string dataSql = String.Format(
            @"SELECT t.TID, t.regno,
                     TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                     t.trans_type, t.amount, t.detail, t.post_status, t.trans_date,
                     t.acadyear, t.semester, t.item_code,
                     CASE WHEN b.ItemName IS NOT NULL AND b.ItemName != '' THEN b.ItemName
                          WHEN t.item_code IS NULL OR t.item_code = 0 THEN '\u2014'
                          ELSE CONCAT('Item ', t.item_code) END AS item_name
              FROM fin_studentfeestracking t
              {1}
              LEFT JOIN academicbillingitems b ON b.ItemCode = t.item_code
              {0}
              ORDER BY t.TID DESC
              LIMIT @pgOffset, @pgSize", where.ToString(), studentJoin);

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // 1. Stats (fast COUNT query)
            cmd.Connection = conn;
            cmd.CommandText = statsSql;
            long totalTx = 0;
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    totalTx   = rdr["total_tx"] != DBNull.Value ? Convert.ToInt64(rdr["total_tx"])   : 0;
                    long billCnt  = rdr["bill_cnt"] != DBNull.Value ? Convert.ToInt64(rdr["bill_cnt"]) : 0;
                    long payCnt   = rdr["pay_cnt"]  != DBNull.Value ? Convert.ToInt64(rdr["pay_cnt"])  : 0;
                    decimal billAmt = rdr["bill_amt"] != DBNull.Value ? Convert.ToDecimal(rdr["bill_amt"]) : 0;
                    decimal payAmt  = rdr["pay_amt"]  != DBNull.Value ? Convert.ToDecimal(rdr["pay_amt"])  : 0;

                    litTotalTx.Text  = totalTx.ToString("N0");
                    litBillTx.Text   = billCnt.ToString("N0");
                    litPayTx.Text    = payCnt.ToString("N0");
                    litBillAmt.Text  = FormatCurrency(billAmt);
                    litPayAmt.Text   = FormatCurrency(payAmt);
                    lblRecordCount.Text = totalTx.ToString("N0") + " records";
                }
            }

            // 2. Clamp page index to valid range
            int totalPages = totalTx > 0 ? (int)Math.Ceiling((double)totalTx / pageSize) : 1;
            if (pageIndex >= totalPages) { pageIndex = Math.Max(0, totalPages - 1); hfPageIndex.Value = pageIndex.ToString(); }
            int offset = pageIndex * pageSize;

            // 3. Page of data
            MySqlCommand dataCmd = new MySqlCommand(dataSql, conn);
            foreach (MySqlParameter p in cmd.Parameters)
                dataCmd.Parameters.AddWithValue(p.ParameterName, p.Value);
            dataCmd.Parameters.AddWithValue("@pgOffset", offset);
            dataCmd.Parameters.AddWithValue("@pgSize",   pageSize);

            MySqlDataAdapter da = new MySqlDataAdapter(dataCmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            rptTransactions.DataSource = dt;
            rptTransactions.DataBind();
            phNoData.Visible = (dt.Rows.Count == 0);

            // 4. Footer info + pager
            long showFrom = totalTx > 0 ? (long)(offset + 1) : 0;
            long showTo   = Math.Min((long)(offset + pageSize), totalTx);
            lblGridFooter.Text = String.Format(
                "Showing <strong>{0}\u2013{1}</strong> of <strong>{2}</strong> transactions ({3} per page)",
                showFrom, showTo, totalTx.ToString("N0"), pageSize);

            litPager.Text = BuildPagerHtml(pageIndex, totalPages);
        }

        // Context badge
        string ctx = "";
        if (!String.IsNullOrEmpty(ddlAcadYear.SelectedValue))
            ctx = ddlAcadYear.SelectedValue;
        if (!String.IsNullOrEmpty(ddlSemester.SelectedValue))
            ctx += " Sem " + ddlSemester.SelectedValue;
        if (!String.IsNullOrEmpty(studStatus))
            ctx += (ctx.Length > 0 ? " | " : "") + studStatus + " students";
        if (!String.IsNullOrEmpty(ctx))
            litAcadContext.Text = "<span class='ft-card__meta'>" + Server.HtmlEncode(ctx.Trim()) + "</span>";
        else
            litAcadContext.Text = "";
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlTransType_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlBillItem_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlPostStatus_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlStudStatus_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlPageSize_Changed(object sender, EventArgs e) { }

    protected void gvTransactions_PageIndexChanged(object sender, EventArgs e) { }
    protected void btnGoToPage_Click(object sender, EventArgs e) { /* page index read from hfPageIndex in LoadTransactions */ }

    protected void btnSearch_Click(object sender, EventArgs e) { LoadTransactions(); }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ddlAcadYear.SelectedIndex = 0;
        ddlSemester.SelectedIndex = 0;
        ddlTransType.SelectedIndex = 0;
        ddlBillItem.SelectedIndex = 0;
        ddlPostStatus.SelectedIndex = 0;
        ddlStudStatus.SelectedIndex = 0; // Reset to "Active" (first item)
        ddlPageSize.SelectedIndex = 0;
        txtSearch.Text = "";
        LoadTransactions();
    }

    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        // Build WHERE (same as LoadTransactions)
        StringBuilder where = new StringBuilder("WHERE 1=1");
        MySqlCommand cmd = new MySqlCommand();

        // Always LEFT JOIN — every transaction shows regardless of student enrolment status.
        string studentJoin = "LEFT JOIN campus_dynamics.acad_student s ON s.regno = t.regno";

        string studStatus = ddlStudStatus.SelectedValue;
        if (!String.IsNullOrEmpty(studStatus))
        {
            where.Append(" AND UPPER(COALESCE(s.new_status,'')) = UPPER(@studStatus)");
            cmd.Parameters.AddWithValue("@studStatus", studStatus);
        }

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
              {1}
              LEFT JOIN academicbillingitems b ON b.ItemCode = t.item_code
              {0}
              ORDER BY t.TID DESC", where.ToString(), studentJoin);

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
        return String.Format("UGX {0:N0}", val);
    }

    private string CsvSafe(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString().Replace("\"", "\"\"");
    }

    // ====================================================================
    // AJAX Student Lookup (lightweight JSON response, no page rendering)
    // ====================================================================
    private void HandleStudentLookup()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string action = (Request.QueryString["ajax"] ?? "").Trim();
        string query = (Request.QueryString["q"] ?? Request.QueryString["regno"] ?? "").Trim();

        if (string.IsNullOrEmpty(query) || query.Length < 2)
        {
            Response.Write("{\"results\":[]}");
            Response.End();
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();

                // Powerful multi-field search: by reg number, student number, first name, other name, or full name
                // Supports partial matching and multiple search terms
                string[] terms = query.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                StringBuilder whereClause = new StringBuilder();
                MySqlCommand cmd = new MySqlCommand();

                // Include all students with a valid status (Active, Admitted, etc.)
                // Only exclude blank/null status records
                whereClause.Append("COALESCE(s.new_status,'') != ''");

                if (terms.Length == 1)
                {
                    // Single term — search across all key fields
                    whereClause.Append(@" AND (
                        s.regno LIKE @q1 
                        OR s.entryno LIKE @q1 
                        OR s.firstname LIKE @q1 
                        OR s.othername LIKE @q1 
                        OR CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')) LIKE @q1
                    )");
                    cmd.Parameters.AddWithValue("@q1", "%" + terms[0] + "%");
                }
                else
                {
                    // Multiple terms — each term must match at least one field (AND logic)
                    // This handles "John Doe" matching firstname=John AND othername=Doe
                    for (int i = 0; i < terms.Length && i < 5; i++)
                    {
                        string pName = "@qt" + i;
                        whereClause.Append(" AND ");
                        whereClause.AppendFormat(@"(
                            s.regno LIKE {0} 
                            OR s.entryno LIKE {0} 
                            OR s.firstname LIKE {0} 
                            OR s.othername LIKE {0}
                        )", pName);
                        cmd.Parameters.AddWithValue(pName, "%" + terms[i] + "%");
                    }
                }

                string sql = String.Format(@"SELECT 
                    s.regno,
                    COALESCE(s.entryno, '') AS studno,
                    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                    COALESCE(p.progname, 'N/A') AS programme,
                    COALESCE(s.studsesion, 'N/A') AS session_name,
                    COALESCE(s.new_status, '') AS status
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON p.progcode = s.progid
                  WHERE {0}
                  ORDER BY 
                    CASE WHEN UPPER(COALESCE(s.new_status,'')) = 'ACTIVE' THEN 0
                         WHEN UPPER(COALESCE(s.new_status,'')) = 'ADMITTED' THEN 1
                         ELSE 2 END,
                    CASE WHEN s.regno LIKE @qExact THEN 0
                         WHEN s.regno LIKE @qStart THEN 1
                         WHEN s.firstname LIKE @qStart THEN 2
                         ELSE 3 END,
                    s.firstname, s.othername
                  LIMIT 15", whereClause.ToString());

                cmd.CommandText = sql;
                cmd.Connection = conn;
                cmd.Parameters.AddWithValue("@qExact", query);
                cmd.Parameters.AddWithValue("@qStart", query + "%");

                StringBuilder json = new StringBuilder();
                json.Append("{\"results\":[");
                bool first = true;

                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        if (!first) json.Append(",");
                        first = false;
                        json.AppendFormat(
                            "{{\"regno\":\"{0}\",\"studno\":\"{1}\",\"name\":\"{2}\",\"programme\":\"{3}\",\"session\":\"{4}\",\"status\":\"{5}\"}}",
                            JsEsc(rdr["regno"].ToString()),
                            JsEsc(rdr["studno"].ToString()),
                            JsEsc(rdr["student_name"].ToString()),
                            JsEsc(rdr["programme"].ToString()),
                            JsEsc(rdr["session_name"].ToString()),
                            JsEsc(rdr["status"].ToString()));
                    }
                }

                json.Append("]}");
                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"results\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }

        Response.End();
    }

    // ====================================================================
    // Save Transaction
    // ====================================================================
    protected void btnSaveTransaction_Click(object sender, EventArgs e)
    {
        // Restore modal posted values
        RestorePostedValue(ddlTxTransType);
        RestorePostedValue(ddlTxBillItem);
        RestorePostedValue(ddlTxAcadYear);
        RestorePostedValue(ddlTxSemester);
        RestorePostedValue(ddlTxPostStatus);

        // Gather values
        string regno = hfSelectedRegNo.Value.Trim();
        string transType = ddlTxTransType.SelectedValue;
        string billItemVal = ddlTxBillItem.SelectedValue;
        string amountStr = txtTxAmount.Text.Trim();
        string acadYear = ddlTxAcadYear.SelectedValue;
        string semesterStr = ddlTxSemester.SelectedValue;
        string detail = txtTxDetail.Text.Trim();
        string dateStr = txtTxDate.Text.Trim();
        string postStatus = ddlTxPostStatus.SelectedValue;

        // ---- Server-side validation ----

        // Required fields
        if (string.IsNullOrEmpty(regno))
        { ShowToast("Registration Number is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(transType))
        { ShowToast("Transaction Type is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(billItemVal))
        { ShowToast("Billing Item is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(amountStr))
        { ShowToast("Amount is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(acadYear))
        { ShowToast("Academic Year is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(semesterStr))
        { ShowToast("Semester is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(detail))
        { ShowToast("Description is required.", false); OpenModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(dateStr))
        { ShowToast("Transaction Date is required.", false); OpenModalAfterPostback(); return; }

        // Amount validation
        double amount;
        if (!double.TryParse(amountStr, out amount) || amount <= 0)
        { ShowToast("Amount must be a positive number.", false); OpenModalAfterPostback(); return; }

        // Semester
        int semester;
        if (!int.TryParse(semesterStr, out semester) || semester < 1 || semester > 3)
        { ShowToast("Invalid semester value.", false); OpenModalAfterPostback(); return; }

        // Item code
        int itemCode;
        if (!int.TryParse(billItemVal, out itemCode))
        { ShowToast("Invalid billing item.", false); OpenModalAfterPostback(); return; }

        // Date
        DateTime transDate;
        if (!DateTime.TryParse(dateStr, out transDate))
        { ShowToast("Invalid transaction date.", false); OpenModalAfterPostback(); return; }

        // Detail max length
        if (detail.Length > 250)
        { ShowToast("Description must be 250 characters or less.", false); OpenModalAfterPostback(); return; }

        // Post status
        if (postStatus != "Pending" && postStatus != "Posted")
            postStatus = "Pending";

        // Trans type whitelist
        if (transType != "Bill" && transType != "Payment")
        { ShowToast("Invalid transaction type.", false); OpenModalAfterPostback(); return; }

        // ---- Verify student exists ----
        bool studentExists = false;
        using (MySqlConnection conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT 1 FROM acad_student WHERE regno = @r LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                object result = cmd.ExecuteScalar();
                studentExists = result != null;
            }
        }
        if (!studentExists)
        { ShowToast("Student with registration number '" + Server.HtmlEncode(regno) + "' was not found.", false); OpenModalAfterPostback(); return; }

        // ---- Check for duplicate (UNIQUE: regno, acadyear, semester, item_code, trans_type) ----
        bool duplicate = false;
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT TID FROM fin_studentfeestracking 
                  WHERE regno = @r AND acadyear = @y AND semester = @s AND item_code = @ic AND trans_type = @tt 
                  LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                cmd.Parameters.AddWithValue("@y", acadYear);
                cmd.Parameters.AddWithValue("@s", semester);
                cmd.Parameters.AddWithValue("@ic", itemCode);
                cmd.Parameters.AddWithValue("@tt", transType);
                object result = cmd.ExecuteScalar();
                duplicate = result != null;
            }
        }
        if (duplicate)
        {
            string itemName = ddlTxBillItem.SelectedItem != null ? ddlTxBillItem.SelectedItem.Text : billItemVal;
            ShowToast(String.Format(
                "Duplicate: A {0} for '{1}' already exists for {2} in {3} Sem {4}.",
                transType, itemName, regno, acadYear, semester), false);
            OpenModalAfterPostback();
            return;
        }

        // ---- INSERT ----
        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                string insertSql = @"INSERT INTO fin_studentfeestracking 
                    (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status) 
                    VALUES (@r, @s, @y, @a, @ic, @tt, @d, @dt, @ps)";
                using (MySqlCommand cmd = new MySqlCommand(insertSql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@y", acadYear);
                    cmd.Parameters.AddWithValue("@a", amount);
                    cmd.Parameters.AddWithValue("@ic", itemCode);
                    cmd.Parameters.AddWithValue("@tt", transType);
                    cmd.Parameters.AddWithValue("@d", detail);
                    cmd.Parameters.AddWithValue("@dt", transDate);
                    cmd.Parameters.AddWithValue("@ps", postStatus);
                    cmd.ExecuteNonQuery();
                }
            }

            string itemText = ddlTxBillItem.SelectedItem != null ? ddlTxBillItem.SelectedItem.Text : billItemVal;
            ShowToast(String.Format(
                "Transaction saved: {0} of UGX {1} for {2} ({3}, {4} Sem {5}).",
                transType, amount.ToString("N0"), regno, itemText, acadYear, semester), true);

            // Clear modal fields
            hfSelectedRegNo.Value = "";
            txtTxAmount.Text = "";
            txtTxDetail.Text = "";
            ddlTxTransType.SelectedIndex = 0;
            ddlTxBillItem.SelectedIndex = 0;
            ddlTxPostStatus.SelectedIndex = 0;

            // Refresh grid
            LoadTransactions();
        }
        catch (MySqlException mex)
        {
            if (mex.Number == 1062) // Duplicate entry (caught by DB unique constraint or trigger)
            {
                ShowToast("This transaction already exists (duplicate detected by database).", false);
            }
            else
            {
                ShowToast("Database error: " + Server.HtmlEncode(mex.Message), false);
            }
            OpenModalAfterPostback();
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
            OpenModalAfterPostback();
        }
    }

    // ====================================================================
    // Edit Transaction
    // ====================================================================
    protected void btnEditTransaction_Click(object sender, EventArgs e)
    {
        // Restore edit modal posted values
        RestorePostedValue(ddlEditTransType);
        RestorePostedValue(ddlEditBillItem);
        RestorePostedValue(ddlEditAcadYear);
        RestorePostedValue(ddlEditSemester);
        RestorePostedValue(ddlEditPostStatus);

        string tidStr = hfEditTID.Value.Trim();
        int tid;
        if (!int.TryParse(tidStr, out tid) || tid <= 0)
        { ShowToast("Invalid transaction ID.", false); return; }

        string transType = ddlEditTransType.SelectedValue;
        string billItemVal = ddlEditBillItem.SelectedValue;
        string amountStr = txtEditAmount.Text.Trim();
        string acadYear = ddlEditAcadYear.SelectedValue;
        string semesterStr = ddlEditSemester.SelectedValue;
        string detail = txtEditDetail.Text.Trim();
        string dateStr = txtEditDate.Text.Trim();
        string postStatus = ddlEditPostStatus.SelectedValue;

        // ---- Validation ----
        if (string.IsNullOrEmpty(transType))
        { ShowToast("Transaction Type is required.", false); OpenEditModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(billItemVal))
        { ShowToast("Billing Item is required.", false); OpenEditModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(amountStr))
        { ShowToast("Amount is required.", false); OpenEditModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(acadYear))
        { ShowToast("Academic Year is required.", false); OpenEditModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(semesterStr))
        { ShowToast("Semester is required.", false); OpenEditModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(detail))
        { ShowToast("Description is required.", false); OpenEditModalAfterPostback(); return; }
        if (string.IsNullOrEmpty(dateStr))
        { ShowToast("Transaction Date is required.", false); OpenEditModalAfterPostback(); return; }

        double amount;
        if (!double.TryParse(amountStr, out amount) || amount <= 0)
        { ShowToast("Amount must be a positive number.", false); OpenEditModalAfterPostback(); return; }

        int semester;
        if (!int.TryParse(semesterStr, out semester) || semester < 1 || semester > 3)
        { ShowToast("Invalid semester.", false); OpenEditModalAfterPostback(); return; }

        int itemCode;
        if (!int.TryParse(billItemVal, out itemCode))
        { ShowToast("Invalid billing item.", false); OpenEditModalAfterPostback(); return; }

        DateTime transDate;
        if (!DateTime.TryParse(dateStr, out transDate))
        { ShowToast("Invalid date.", false); OpenEditModalAfterPostback(); return; }

        if (detail.Length > 250)
        { ShowToast("Description must be 250 characters or less.", false); OpenEditModalAfterPostback(); return; }

        if (postStatus != "Pending" && postStatus != "Posted") postStatus = "Pending";
        if (transType != "Bill" && transType != "Payment")
        { ShowToast("Invalid transaction type.", false); OpenEditModalAfterPostback(); return; }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // ---- Audit: capture BEFORE the UPDATE ----
                InsertAuditRecord(conn, tid, "EDIT",
                    newTransType: transType, newItemCode: itemCode, newAmount: amount,
                    newDetail: detail, newTransDate: transDate, newAcadYear: acadYear,
                    newSemester: semester, newPostStatus: postStatus);

                string sql = @"UPDATE fin_studentfeestracking SET 
                    trans_type=@tt, item_code=@ic, amount=@a, detail=@d, trans_date=@dt, 
                    acadyear=@y, semester=@s, post_status=@ps 
                    WHERE TID=@tid";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@tt", transType);
                    cmd.Parameters.AddWithValue("@ic", itemCode);
                    cmd.Parameters.AddWithValue("@a", amount);
                    cmd.Parameters.AddWithValue("@d", detail);
                    cmd.Parameters.AddWithValue("@dt", transDate);
                    cmd.Parameters.AddWithValue("@y", acadYear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@ps", postStatus);
                    cmd.Parameters.AddWithValue("@tid", tid);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        string itemText = ddlEditBillItem.SelectedItem != null ? ddlEditBillItem.SelectedItem.Text : billItemVal;
                        ShowToast(String.Format("Transaction #{0} updated — {1} of UGX {2} ({3}).",
                            tid, transType, amount.ToString("N0"), itemText), true);
                    }
                    else
                    {
                        ShowToast("Transaction #" + tid + " was not found.", false);
                    }
                }
            }
            LoadTransactions();
        }
        catch (Exception ex)
        {
            ShowToast("Error updating: " + Server.HtmlEncode(ex.Message), false);
            OpenEditModalAfterPostback();
        }
    }

    // ====================================================================
    // Delete Transaction
    // ====================================================================
    protected void btnDeleteTransaction_Click(object sender, EventArgs e)
    {
        string tidStr = hfDeleteTID.Value.Trim();
        int tid;
        if (!int.TryParse(tidStr, out tid) || tid <= 0)
        { ShowToast("Invalid transaction ID.", false); return; }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // ---- Audit: capture BEFORE the DELETE ----
                InsertAuditRecord(conn, tid, "DELETE");

                using (MySqlCommand cmd = new MySqlCommand("DELETE FROM fin_studentfeestracking WHERE TID=@tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", tid);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        ShowToast("Transaction #" + tid + " has been deleted.", true);
                    }
                    else
                    {
                        ShowToast("Transaction #" + tid + " was not found.", false);
                    }
                }
            }
            LoadTransactions();
        }
        catch (Exception ex)
        {
            ShowToast("Error deleting: " + Server.HtmlEncode(ex.Message), false);
        }
    }

    // ====================================================================
    // Audit Trail Helper
    // ====================================================================
    private string GetCurrentUser()
    {
        if (Session["ScreenName"] != null) return Session["ScreenName"].ToString();
        if (Session["username"] != null) return Session["username"].ToString();
        return "Unknown";
    }

    /// <summary>
    /// Reads the original row from fin_studentfeestracking and inserts an immutable audit record.
    /// Call BEFORE the UPDATE or DELETE so original values are captured.
    /// </summary>
    private void InsertAuditRecord(MySqlConnection conn, int tid, string actionType,
        string newTransType = null, int? newItemCode = null, double? newAmount = null,
        string newDetail = null, DateTime? newTransDate = null, string newAcadYear = null,
        int? newSemester = null, string newPostStatus = null, string reason = null)
    {
        // 1. Fetch the original row
        DataRow orig = null;
        using (MySqlCommand sel = new MySqlCommand(
            "SELECT regno, trans_type, item_code, amount, detail, trans_date, acadyear, semester, post_status FROM fin_studentfeestracking WHERE TID=@tid", conn))
        {
            sel.Parameters.AddWithValue("@tid", tid);
            using (MySqlDataAdapter da = new MySqlDataAdapter(sel))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                if (dt.Rows.Count == 0) return; // row not found — nothing to audit
                orig = dt.Rows[0];
            }
        }

        // 2. Insert the audit record
        string auditSql = @"INSERT INTO fin_changed_deleted_transactions 
            (action_type, original_tid, orig_regno, orig_trans_type, orig_item_code, orig_amount, orig_detail, orig_trans_date, orig_acadyear, orig_semester, orig_post_status,
             new_trans_type, new_item_code, new_amount, new_detail, new_trans_date, new_acadyear, new_semester, new_post_status,
             changed_by, ip_address, reason)
            VALUES
            (@action, @tid, @oRegno, @oTT, @oIC, @oAmt, @oDet, @oDate, @oYear, @oSem, @oPS,
             @nTT, @nIC, @nAmt, @nDet, @nDate, @nYear, @nSem, @nPS,
             @user, @ip, @reason)";
        using (MySqlCommand ins = new MySqlCommand(auditSql, conn))
        {
            ins.Parameters.AddWithValue("@action", actionType);
            ins.Parameters.AddWithValue("@tid", tid);
            ins.Parameters.AddWithValue("@oRegno", orig["regno"]);
            ins.Parameters.AddWithValue("@oTT", orig["trans_type"]);
            ins.Parameters.AddWithValue("@oIC", orig["item_code"]);
            ins.Parameters.AddWithValue("@oAmt", orig["amount"]);
            ins.Parameters.AddWithValue("@oDet", orig["detail"] == DBNull.Value ? (object)DBNull.Value : orig["detail"]);
            ins.Parameters.AddWithValue("@oDate", orig["trans_date"]);
            ins.Parameters.AddWithValue("@oYear", orig["acadyear"]);
            ins.Parameters.AddWithValue("@oSem", orig["semester"]);
            ins.Parameters.AddWithValue("@oPS", orig["post_status"]);

            // For DELETE, new values are NULL
            ins.Parameters.AddWithValue("@nTT", actionType == "DELETE" ? (object)DBNull.Value : newTransType);
            ins.Parameters.AddWithValue("@nIC", actionType == "DELETE" ? (object)DBNull.Value : (object)(newItemCode ?? (object)DBNull.Value));
            ins.Parameters.AddWithValue("@nAmt", actionType == "DELETE" ? (object)DBNull.Value : (object)(newAmount ?? (object)DBNull.Value));
            ins.Parameters.AddWithValue("@nDet", actionType == "DELETE" ? (object)DBNull.Value : (object)(newDetail ?? (object)DBNull.Value));
            ins.Parameters.AddWithValue("@nDate", actionType == "DELETE" ? (object)DBNull.Value : (object)(newTransDate ?? (object)DBNull.Value));
            ins.Parameters.AddWithValue("@nYear", actionType == "DELETE" ? (object)DBNull.Value : (object)(newAcadYear ?? (object)DBNull.Value));
            ins.Parameters.AddWithValue("@nSem", actionType == "DELETE" ? (object)DBNull.Value : (object)(newSemester ?? (object)DBNull.Value));
            ins.Parameters.AddWithValue("@nPS", actionType == "DELETE" ? (object)DBNull.Value : (object)(newPostStatus ?? (object)DBNull.Value));

            ins.Parameters.AddWithValue("@user", GetCurrentUser());
            ins.Parameters.AddWithValue("@ip", Request.UserHostAddress ?? "");
            ins.Parameters.AddWithValue("@reason", reason ?? (object)DBNull.Value);

            ins.ExecuteNonQuery();
        }
    }

    // ====================================================================
    // Helpers
    // ====================================================================
    protected string FormatDateISO(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        try { return Convert.ToDateTime(val).ToString("yyyy-MM-dd"); }
        catch { return val.ToString(); }
    }

    protected string FormatDateShort(object val)
    {
        if (val == null || val == DBNull.Value) return "\u2014";
        try { return Convert.ToDateTime(val).ToString("d MMM yyyy"); }
        catch { return val.ToString(); }
    }

    protected string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private void ShowToast(string message, bool success)
    {
        pnlToast.Visible = true;
        divToast.Attributes["class"] = success ? "fs-toast fs-toast--success" : "fs-toast fs-toast--error";
        divToast.InnerHtml = Server.HtmlEncode(message);
    }

    private void OpenModalAfterPostback()
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "reopenModal",
            "setTimeout(function(){ openModal('modal-add-tx'); var b=document.getElementById('btnModalSave'); if(b){b.disabled=false;b.innerText='Save Transaction';} },100);", true);
    }

    private void OpenEditModalAfterPostback()
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "reopenEditModal",
            "setTimeout(function(){ openModal('modal-edit-tx'); var b=document.getElementById('btnModalEdit'); if(b){b.disabled=false;b.innerHTML='<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"12\" height=\"12\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><polyline points=\"20 6 9 17 4 12\"></polyline></svg> Update Transaction';} },100);", true);
    }

    private static string JsEsc(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }

    // ====================================================================
    // BuildPagerHtml — renders prev/page-numbers/next pager buttons
    // ====================================================================
    private string BuildPagerHtml(int pageIndex, int totalPages)
    {
        if (totalPages <= 1) return "";
        var sb = new System.Text.StringBuilder();
        sb.Append("<div class=\"ft-pager__btns\">");
        bool isFirst = (pageIndex == 0);
        bool isLast  = (pageIndex >= totalPages - 1);

        sb.AppendFormat("<button type=\"button\" class=\"ft-pager__btn\" onclick=\"goToPage(0)\" {0}>&laquo;</button>",
            isFirst ? "disabled" : "");
        sb.AppendFormat("<button type=\"button\" class=\"ft-pager__btn\" onclick=\"goToPage({0})\" {1}>&lsaquo; Prev</button>",
            pageIndex - 1, isFirst ? "disabled" : "");

        int startP = Math.Max(0, pageIndex - 3);
        int endP   = Math.Min(totalPages - 1, pageIndex + 3);

        if (startP > 0)
            sb.Append("<span class=\"ft-pager__ellipsis\">&hellip;</span>");

        for (int i = startP; i <= endP; i++)
        {
            bool active = (i == pageIndex);
            sb.AppendFormat(
                "<button type=\"button\" class=\"ft-pager__btn{0}\" onclick=\"goToPage({1})\">{2}</button>",
                active ? " ft-pager__btn--active" : "", i, i + 1);
        }

        if (endP < totalPages - 1)
            sb.Append("<span class=\"ft-pager__ellipsis\">&hellip;</span>");

        sb.AppendFormat("<button type=\"button\" class=\"ft-pager__btn\" onclick=\"goToPage({0})\" {1}>Next &rsaquo;</button>",
            pageIndex + 1, isLast ? "disabled" : "");
        sb.AppendFormat("<button type=\"button\" class=\"ft-pager__btn\" onclick=\"goToPage({0})\" {1}>&raquo;</button>",
            totalPages - 1, isLast ? "disabled" : "");

        sb.Append("</div>");
        return sb.ToString();
    }
}
