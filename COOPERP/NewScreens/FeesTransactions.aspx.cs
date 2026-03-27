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
        if (Request.QueryString["ajax"] == "lookup")
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

        // Restore posted dropdown values
        RestorePostedValue(ddlAcadYear);
        RestorePostedValue(ddlSemester);
        RestorePostedValue(ddlTransType);
        RestorePostedValue(ddlBillItem);
        RestorePostedValue(ddlPostStatus);
        RestorePostedValue(ddlPageSize);

        if (!IsPostBack)
        {
            // Default to current academic year
            string curYear = AcademicYearHelper.GetCurrentAcademicYear();
            if (ddlAcadYear.Items.FindByValue(curYear) != null)
                ddlAcadYear.SelectedValue = curYear;
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

        // Data query — no LIMIT; DX grid handles paging natively
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
              ORDER BY t.TID DESC", where.ToString());

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

            int totalRows = dt.Rows.Count;
            int totalPages = (int)Math.Ceiling((double)totalRows / pageSize);
            int currentPage = gvTransactions.PageIndex + 1;
            lblGridFooter.Text = String.Format(
                "Showing page <strong>{0}</strong> of <strong>{1}</strong> &mdash; <strong>{2}</strong> total transactions ({3} per page)",
                currentPage, totalPages, totalRows.ToString("N0"), pageSize);
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

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlTransType_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlBillItem_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlPostStatus_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlPageSize_Changed(object sender, EventArgs e) { }

    protected void gvTransactions_PageIndexChanged(object sender, EventArgs e) { }

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

    // ====================================================================
    // AJAX Student Lookup (lightweight JSON response, no page rendering)
    // ====================================================================
    private void HandleStudentLookup()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"found\":false}");
            Response.End();
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                string sql = @"SELECT 
                    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                    COALESCE(p.programme,'N/A') AS programme,
                    COALESCE(s.studsesion,'N/A') AS session_name
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON p.progid = s.progid
                  WHERE s.regno = @r
                  LIMIT 1";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string name = rdr["student_name"].ToString();
                            string prog = rdr["programme"].ToString();
                            string sess = rdr["session_name"].ToString();
                            // Simple JSON (no framework dependency)
                            Response.Write(String.Format(
                                "{{\"found\":true,\"name\":\"{0}\",\"programme\":\"{1}\",\"session\":\"{2}\"}}",
                                JsEsc(name), JsEsc(prog), JsEsc(sess)));
                        }
                        else
                        {
                            Response.Write("{\"found\":false}");
                        }
                    }
                }
            }
        }
        catch
        {
            Response.Write("{\"found\":false}");
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
        string regno = txtTxRegNo.Text.Trim();
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
            txtTxRegNo.Text = "";
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
    // Helpers
    // ====================================================================
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

    private static string JsEsc(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }
}
