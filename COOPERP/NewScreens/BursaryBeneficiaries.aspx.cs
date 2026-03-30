using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_BursaryBeneficiaries : System.Web.UI.Page
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
        // AJAX student search
        string ajax = Request.QueryString["ajax"];
        if (ajax == "search")
        {
            HandleStudentSearch();
            return;
        }
        if (ajax == "getreg")
        {
            HandleGetRegistration();
            return;
        }

        txtEditAmount.Attributes["type"] = "number";
        txtEditAmount.Attributes["min"] = "0";
        txtEditAmount.Attributes["step"] = "1";
        txtEditTxRef.Attributes["type"] = "number";
        txtEditTxRef.Attributes["min"] = "0";

        LoadLookups();

        // Restore filter dropdowns (ViewState disabled on master page)
        RestorePostedValue(ddlScheme);
        RestorePostedValue(ddlAcadYear);
        RestorePostedValue(ddlSemester);
        RestorePostedValue(ddlPageSize);

        // Restore modal dropdowns
        RestorePostedValue(ddlAddScheme);
        RestorePostedValue(ddlAddAcadYear);
        RestorePostedValue(ddlAddSemester);
        RestorePostedValue(ddlEditScheme);
        RestorePostedValue(ddlEditAcadYear);
        RestorePostedValue(ddlEditSemester);

        // Check query string for scheme pre-filter
        if (!IsPostBack)
        {
            string schemeQs = Request.QueryString["scheme"];
            if (!string.IsNullOrEmpty(schemeQs))
            {
                ListItem li = ddlScheme.Items.FindByValue(schemeQs);
                if (li != null) { ddlScheme.ClearSelection(); li.Selected = true; }
            }
        }

        LoadBeneficiaries();
    }

    // ====================================================================
    // AJAX Student Search
    // ====================================================================
    private void HandleStudentSearch()
    {
        Response.ContentType = "application/json";
        string q = (Request.QueryString["q"] ?? "").Trim();
        if (q.Length < 2) { Response.Write("[]"); Response.End(); return; }

        var sb = new StringBuilder("[");
        using (MySqlConnection conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            string sql = @"SELECT s.regno, CONCAT(s.firstname,' ',s.othername) AS student_name, 
                                  IFNULL(p.progname,'') AS programme
                           FROM acad_student s
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           WHERE s.regno LIKE @q OR CONCAT(s.firstname,' ',s.othername) LIKE @q
                           LIMIT 15";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    bool first = true;
                    while (rdr.Read())
                    {
                        if (!first) sb.Append(",");
                        first = false;
                        sb.AppendFormat("{{\"regno\":\"{0}\",\"name\":\"{1}\",\"programme\":\"{2}\"}}",
                            JsEsc(rdr["regno"].ToString()),
                            JsEsc(rdr["student_name"].ToString()),
                            JsEsc(rdr["programme"].ToString()));
                    }
                }
            }
        }
        sb.Append("]");
        Response.Write(sb.ToString());
        Response.End();
    }

    // ====================================================================
    // AJAX Get Registration
    // ====================================================================
    private void HandleGetRegistration()
    {
        Response.ContentType = "application/json";
        string reg = (Request.QueryString["r"] ?? "").Trim();
        if (string.IsNullOrEmpty(reg)) { Response.Write("{\"found\":false}"); Response.End(); return; }

        using (MySqlConnection conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            // Get the most recent REGISTERED semester for this student
            string sql = @"SELECT r.acad_year, r.semester, r.studyyear, r.regstatus,
                                  CONCAT(s.firstname,' ',s.othername) AS student_name,
                                  IFNULL(p.progname,'') AS programme
                           FROM acad_registration r
                           JOIN acad_student s ON s.regno = r.regno
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           WHERE LOWER(r.regno) = LOWER(@r)
                           ORDER BY r.acad_year DESC, r.semester DESC
                           LIMIT 1";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@r", reg);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string status = rdr["regstatus"].ToString();
                        Response.Write(string.Format(
                            "{{\"found\":true,\"acad_year\":\"{0}\",\"semester\":{1},\"study_year\":{2},\"regstatus\":\"{3}\",\"name\":\"{4}\",\"programme\":\"{5}\"}}",
                            JsEsc(rdr["acad_year"].ToString()),
                            rdr["semester"],
                            rdr["studyyear"],
                            JsEsc(status),
                            JsEsc(rdr["student_name"].ToString()),
                            JsEsc(rdr["programme"].ToString())));
                    }
                    else
                    {
                        Response.Write("{\"found\":false}");
                    }
                }
            }
        }
        Response.End();
    }

    // ====================================================================
    // Load Lookups
    // ====================================================================
    private void LoadLookups()
    {
        // Schemes dropdown (for filter and modals)
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            DataTable dtSchemes = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand("SELECT scholarshipID, scholarshipName, bursary_amount FROM scholarships ORDER BY scholarshipName", conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dtSchemes); }

            // Filter dropdown
            ddlScheme.Items.Clear();
            ddlScheme.Items.Add(new ListItem("All Schemes", ""));
            foreach (DataRow r in dtSchemes.Rows)
                ddlScheme.Items.Add(new ListItem(r["scholarshipName"].ToString(), r["scholarshipID"].ToString()));

            // Add modal dropdown (include amount as data attribute via text suffix)
            ddlAddScheme.Items.Clear();
            ddlAddScheme.Items.Add(new ListItem("-- Select Scheme --", ""));
            foreach (DataRow r in dtSchemes.Rows)
            {
                double schAmt = r["bursary_amount"] != DBNull.Value ? Convert.ToDouble(r["bursary_amount"]) : 0;
                ddlAddScheme.Items.Add(new ListItem(
                    r["scholarshipName"].ToString() + " — UGX " + schAmt.ToString("N0"),
                    r["scholarshipID"].ToString()));
            }

            // Edit modal dropdown
            ddlEditScheme.Items.Clear();
            foreach (DataRow r in dtSchemes.Rows)
            {
                double schAmt = r["bursary_amount"] != DBNull.Value ? Convert.ToDouble(r["bursary_amount"]) : 0;
                ddlEditScheme.Items.Add(new ListItem(
                    r["scholarshipName"].ToString() + " — UGX " + schAmt.ToString("N0"),
                    r["scholarshipID"].ToString()));
            }

            // Store scheme amounts as JSON for JS auto-fill
            var sbAmounts = new StringBuilder("{");
            bool firstScheme = true;
            foreach (DataRow r in dtSchemes.Rows)
            {
                if (!firstScheme) sbAmounts.Append(",");
                firstScheme = false;
                double schAmt = r["bursary_amount"] != DBNull.Value ? Convert.ToDouble(r["bursary_amount"]) : 0;
                sbAmounts.AppendFormat("\"{0}\":{1}", r["scholarshipID"], schAmt);
            }
            sbAmounts.Append("}");
            ScriptManager.RegisterStartupScript(this, GetType(), "schemeAmounts",
                "var _schemeAmounts = " + sbAmounts.ToString() + ";", true);

            // Academic years
            DataTable dtYears = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT DISTINCT acadyear FROM fin_studentfeestracking WHERE acadyear<>'' 
                  UNION SELECT DISTINCT scholarhipYear FROM scholarshipstudents WHERE scholarhipYear<>''
                  ORDER BY acadyear DESC", conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dtYears); }

            ddlAcadYear.Items.Clear();
            ddlAcadYear.Items.Add(new ListItem("All Years", ""));
            ddlAddAcadYear.Items.Clear();
            ddlEditAcadYear.Items.Clear();
            foreach (DataRow r in dtYears.Rows)
            {
                string yr = r[0].ToString();
                ddlAcadYear.Items.Add(new ListItem(yr, yr));
                ddlAddAcadYear.Items.Add(new ListItem(yr, yr));
                ddlEditAcadYear.Items.Add(new ListItem(yr, yr));
            }
        }
    }

    private void RestorePostedValue(DropDownList ddl)
    {
        string posted = Request.Form[ddl.UniqueID];
        if (!string.IsNullOrEmpty(posted))
        {
            ListItem li = ddl.Items.FindByValue(posted);
            if (li != null) { ddl.ClearSelection(); li.Selected = true; }
        }
    }

    // ====================================================================
    // Load Beneficiaries
    // ====================================================================
    private void LoadBeneficiaries()
    {
        string search = txtSearch.Text.Trim();
        string schemeFilter = ddlScheme.SelectedValue;
        string yearFilter = ddlAcadYear.SelectedValue;
        string semFilter = ddlSemester.SelectedValue;

        int pageSize = 50;
        int.TryParse(ddlPageSize.SelectedValue, out pageSize);
        if (pageSize < 1) pageSize = 50;

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Stats query (unfiltered)
            using (MySqlCommand cmdStats = new MySqlCommand(
                @"SELECT COUNT(*) AS total,
                         IFNULL(SUM(ss.amount_offered),0) AS total_amount
                  FROM scholarshipstudents ss", conn))
            {
                using (MySqlDataReader rdr = cmdStats.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litTotal.Text = rdr["total"].ToString();
                        double totalAmt = Convert.ToDouble(rdr["total_amount"]);
                        litTotalAmount.Text = "UGX " + totalAmt.ToString("N0");
                    }
                }
            }

            // Filtered data query
            var where = new List<string>();
            var parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(schemeFilter))
            {
                where.Add("ss.scholarshipID = @scheme");
                parms.Add(new MySqlParameter("@scheme", int.Parse(schemeFilter)));
            }
            if (!string.IsNullOrEmpty(yearFilter))
            {
                where.Add("ss.scholarhipYear = @year");
                parms.Add(new MySqlParameter("@year", yearFilter));
            }
            if (!string.IsNullOrEmpty(semFilter))
            {
                where.Add("ss.scholarhipTerm = @sem");
                parms.Add(new MySqlParameter("@sem", int.Parse(semFilter)));
            }
            if (!string.IsNullOrEmpty(search))
            {
                where.Add("(ss.adm_no LIKE @search OR s.scholarshipName LIKE @search OR CONCAT(st.firstname,' ',st.othername) LIKE @search)");
                parms.Add(new MySqlParameter("@search", "%" + search + "%"));
            }

            string whereClause = where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";

            string sql = @"SELECT ss.stid, ss.adm_no, ss.scholarshipID, ss.scholarhipTerm, ss.scholarhipYear,
                                  ss.amountDue, ss.amount_offered, ss.transaction_ref, ss.status, ss.date_added, ss.notes,
                                  s.scholarshipName,
                                  IFNULL(CONCAT(st.firstname,' ',st.othername),'—') AS student_name,
                                  GREATEST(1, CAST(SUBSTRING(ss.scholarhipYear,1,4) AS SIGNED) - CAST(SUBSTRING(ss.adm_no,4,4) AS SIGNED) + 1) AS study_year
                           FROM scholarshipstudents ss
                           LEFT JOIN scholarships s ON s.scholarshipID = ss.scholarshipID
                           LEFT JOIN campus_dynamics.acad_student st ON st.regno = ss.adm_no"
                         + whereClause + " ORDER BY ss.date_added DESC LIMIT @limit";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                foreach (var p in parms) cmd.Parameters.Add(p);
                cmd.Parameters.AddWithValue("@limit", pageSize);

                DataTable dt = new DataTable();
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }

                gvBeneficiaries.DataSource = dt;
                gvBeneficiaries.SettingsPager.PageSize = pageSize;
                gvBeneficiaries.DataBind();

                lblRecordCount.Text = dt.Rows.Count + " record" + (dt.Rows.Count != 1 ? "s" : "");
                litFooter.Text = string.Format("Showing <strong>{0}</strong> beneficiar{1}",
                    dt.Rows.Count, dt.Rows.Count != 1 ? "ies" : "y");

                // Filter info label
                var filters = new List<string>();
                if (!string.IsNullOrEmpty(schemeFilter)) filters.Add("Scheme: " + (ddlScheme.SelectedItem != null ? ddlScheme.SelectedItem.Text : schemeFilter));
                if (!string.IsNullOrEmpty(yearFilter)) filters.Add(yearFilter);
                if (!string.IsNullOrEmpty(semFilter)) filters.Add("Sem " + semFilter);
                lblFilterInfo.Text = filters.Count > 0 ? string.Join(" | ", filters) : "";
            }
        }
    }

    // ====================================================================
    // Add Beneficiary
    // ====================================================================
    protected void btnSaveBeneficiary_Click(object sender, EventArgs e)
    {
        RestorePostedValue(ddlAddScheme);
        RestorePostedValue(ddlAddAcadYear);
        RestorePostedValue(ddlAddSemester);

        string regNo = hfAddRegNo.Value.Trim();
        if (string.IsNullOrEmpty(regNo)) regNo = txtAddRegNo.Text.Trim();
        string schemeVal = ddlAddScheme.SelectedValue;
        string yearVal   = ddlAddAcadYear.SelectedValue;
        string semVal    = ddlAddSemester.SelectedValue;
        string notes     = txtAddNotes.Text.Trim();

        // Validation
        if (string.IsNullOrEmpty(regNo))
        { ShowToast("Student Reg No is required.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }
        if (string.IsNullOrEmpty(schemeVal))
        { ShowToast("Bursary Scheme is required.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }
        if (string.IsNullOrEmpty(yearVal))
        { ShowToast("Academic Year is required.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }
        if (string.IsNullOrEmpty(semVal))
        { ShowToast("Semester is required.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }

        // Validate that student is registered for this academic year and semester
        try
        {
            using (MySqlConnection connReg = new MySqlConnection(MainConnStr))
            {
                connReg.Open();
                using (MySqlCommand chkReg = new MySqlCommand(
                    @"SELECT regstatus FROM acad_registration 
                      WHERE LOWER(regno) = LOWER(@r) AND acad_year = @y AND semester = @s
                      LIMIT 1", connReg))
                {
                    chkReg.Parameters.AddWithValue("@r", regNo);
                    chkReg.Parameters.AddWithValue("@y", yearVal);
                    chkReg.Parameters.AddWithValue("@s", semVal);
                    object regResult = chkReg.ExecuteScalar();
                    if (regResult == null || regResult == DBNull.Value)
                    {
                        ShowToast("Student '" + regNo + "' has no registration record for " + yearVal + " Semester " + semVal + ". Please verify.", false);
                        OpenModalAfterPostback("modal-add-beneficiary");
                        return;
                    }
                    string regStatus = regResult.ToString().Trim().ToUpper();
                    // Accept: REGISTERED, CLEARED, LATE REGISTERED, LATE-REGISTERED
                    bool validEnrolment = regStatus == "REGISTERED" || regStatus == "CLEARED"
                                      || regStatus == "LATE REGISTERED" || regStatus == "LATE-REGISTERED";
                    if (!validEnrolment)
                    {
                        ShowToast("Student '" + regNo + "' cannot receive a bursary — registration status is '" + regResult.ToString() + "' for " + yearVal + " Semester " + semVal + ".", false);
                        OpenModalAfterPostback("modal-add-beneficiary");
                        return;
                    }
                }
            }
        }
        catch (Exception exReg)
        {
            ShowToast("Registration check failed: " + Server.HtmlEncode(exReg.Message), false);
            OpenModalAfterPostback("modal-add-beneficiary");
            return;
        }

        int schemeId;
        if (!int.TryParse(schemeVal, out schemeId))
        { ShowToast("Invalid bursary scheme.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }

        int semester;
        if (!int.TryParse(semVal, out semester) || semester < 1 || semester > 3)
        { ShowToast("Invalid semester.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }

        if (notes.Length > 500) notes = notes.Substring(0, 500);

        try
        {
            // Verify student exists
            using (MySqlConnection connMain = new MySqlConnection(MainConnStr))
            {
                connMain.Open();
                using (MySqlCommand chk = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE regno=@r", connMain))
                {
                    chk.Parameters.AddWithValue("@r", regNo);
                    if (Convert.ToInt64(chk.ExecuteScalar()) == 0)
                    { ShowToast("Student '" + regNo + "' not found in the system.", false); OpenModalAfterPostback("modal-add-beneficiary"); return; }
                }
            }

            double schemeAmount = 0;
            string schemeName = "";
            long newTID = 0;

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Look up the scheme's bursary amount
                using (MySqlCommand cmdScheme = new MySqlCommand(
                    "SELECT scholarshipName, bursary_amount FROM scholarships WHERE scholarshipID=@id AND status='Active'", conn))
                {
                    cmdScheme.Parameters.AddWithValue("@id", schemeId);
                    using (MySqlDataReader rdr = cmdScheme.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            schemeName = rdr["scholarshipName"].ToString();
                            schemeAmount = rdr["bursary_amount"] != DBNull.Value ? Convert.ToDouble(rdr["bursary_amount"]) : 0;
                        }
                        else
                        {
                            ShowToast("Selected scheme is not active or does not exist.", false);
                            OpenModalAfterPostback("modal-add-beneficiary");
                            return;
                        }
                    }
                }

                if (schemeAmount <= 0)
                {
                    ShowToast("This scheme has no bursary amount configured. Please set the amount on the Bursary Schemes page first.", false);
                    OpenModalAfterPostback("modal-add-beneficiary");
                    return;
                }

                // Check for duplicate (same student + scheme + year + semester)
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM scholarshipstudents WHERE adm_no=@r AND scholarshipID=@s AND scholarhipYear=@y AND scholarhipTerm=@t", conn))
                {
                    chk.Parameters.AddWithValue("@r", regNo);
                    chk.Parameters.AddWithValue("@s", schemeId);
                    chk.Parameters.AddWithValue("@y", yearVal);
                    chk.Parameters.AddWithValue("@t", semester);
                    if (Convert.ToInt64(chk.ExecuteScalar()) > 0)
                    {
                        ShowToast("This student is already a beneficiary of this scheme for " + yearVal + " Semester " + semester + ".", false);
                        OpenModalAfterPostback("modal-add-beneficiary");
                        return;
                    }
                }

                // Delegate to BursaryManager (atomic — all 3 tables in one transaction)
                int itemCode = BursaryManager.GetOrCreateBillingItem(conn);
                var result   = BursaryManager.Create(conn, regNo, schemeId, schemeName, schemeAmount, yearVal, semester, itemCode, notes);

                if (result.Success)
                {
                    hfAddRegNo.Value = ""; txtAddRegNo.Text = ""; txtAddNotes.Text = "";
                    string displayName = ddlAddScheme.SelectedItem != null ? ddlAddScheme.SelectedItem.Text : schemeVal;
                    ShowToast(string.Format("Beneficiary {0} added to {1} ({2} Sem {3}) — UGX {4}. Fee transaction #{5} created.",
                        regNo, displayName, yearVal, semester, schemeAmount.ToString("N0"), result.TID), true);
                    LoadBeneficiaries();
                }
                else
                {
                    ShowToast("Error: " + result.Message, false);
                    OpenModalAfterPostback("modal-add-beneficiary");
                }
            }
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
            OpenModalAfterPostback("modal-add-beneficiary");
        }
    }

    // ====================================================================
    // Edit Beneficiary
    // ====================================================================
    protected void btnEditBeneficiary_Click(object sender, EventArgs e)
    {
        RestorePostedValue(ddlEditScheme);
        RestorePostedValue(ddlEditAcadYear);
        RestorePostedValue(ddlEditSemester);

        string idStr     = hfEditID.Value.Trim();
        string schemeVal = ddlEditScheme.SelectedValue;
        string yearVal   = ddlEditAcadYear.SelectedValue;
        string semVal    = ddlEditSemester.SelectedValue;
        string amountStr = txtEditAmount.Text.Trim();
        string notes     = txtEditNotes.Text.Trim();

        int id;
        if (!int.TryParse(idStr, out id) || id <= 0)
        { ShowToast("Invalid beneficiary ID.", false); return; }
        if (string.IsNullOrEmpty(schemeVal))
        { ShowToast("Bursary Scheme is required.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }
        if (string.IsNullOrEmpty(yearVal))
        { ShowToast("Academic Year is required.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }
        if (string.IsNullOrEmpty(semVal))
        { ShowToast("Semester is required.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }
        if (string.IsNullOrEmpty(amountStr))
        { ShowToast("Amount is required.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }

        int schemeId;
        if (!int.TryParse(schemeVal, out schemeId))
        { ShowToast("Invalid scheme.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }
        int semester;
        if (!int.TryParse(semVal, out semester) || semester < 1 || semester > 3)
        { ShowToast("Invalid semester.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }
        double amount;
        if (!double.TryParse(amountStr, out amount) || amount < 0)
        { ShowToast("Amount must be a positive number.", false); OpenModalAfterPostback("modal-edit-beneficiary"); return; }
        if (notes.Length > 500) notes = notes.Substring(0, 500);

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                int itemCode = BursaryManager.GetOrCreateBillingItem(conn);
                var result   = BursaryManager.Update(conn, id, schemeId, yearVal, semester, amount, notes, itemCode);
                ShowToast(result.Message, result.Success);
                if (!result.Success) OpenModalAfterPostback("modal-edit-beneficiary");
                else LoadBeneficiaries();
            }
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
            OpenModalAfterPostback("modal-edit-beneficiary");
        }
    }

    // ====================================================================
    // Delete Beneficiary
    // ====================================================================
    protected void btnDeleteBeneficiary_Click(object sender, EventArgs e)
    {
        string idStr = hfDeleteID.Value.Trim();
        int id;
        if (!int.TryParse(idStr, out id) || id <= 0)
        { ShowToast("Invalid beneficiary ID.", false); return; }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                var result = BursaryManager.Delete(conn, id);
                ShowToast(result.Message, result.Success);
            }
            LoadBeneficiaries();
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
        }
    }

    // ====================================================================
    // Export CSV
    // ====================================================================
    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        RestorePostedValue(ddlScheme);
        RestorePostedValue(ddlAcadYear);
        RestorePostedValue(ddlSemester);

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            var where = new List<string>();
            var parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(ddlScheme.SelectedValue)) { where.Add("ss.scholarshipID=@scheme"); parms.Add(new MySqlParameter("@scheme", int.Parse(ddlScheme.SelectedValue))); }
            if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue)) { where.Add("ss.scholarhipYear=@year"); parms.Add(new MySqlParameter("@year", ddlAcadYear.SelectedValue)); }
            if (!string.IsNullOrEmpty(ddlSemester.SelectedValue)) { where.Add("ss.scholarhipTerm=@sem"); parms.Add(new MySqlParameter("@sem", int.Parse(ddlSemester.SelectedValue))); }
            string search = txtSearch.Text.Trim();
            if (!string.IsNullOrEmpty(search)) { where.Add("(ss.adm_no LIKE @search OR s.scholarshipName LIKE @search OR CONCAT(st.firstname,' ',st.othername) LIKE @search)"); parms.Add(new MySqlParameter("@search", "%" + search + "%")); }

            string whereClause = where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";

            string sql = @"SELECT ss.stid, ss.adm_no, IFNULL(CONCAT(st.firstname,' ',st.othername),'') AS student_name,
                                  s.scholarshipName, ss.scholarhipYear, ss.scholarhipTerm, ss.amount_offered,
                                  ss.status, ss.transaction_ref, ss.date_added, ss.notes
                           FROM scholarshipstudents ss
                           LEFT JOIN scholarships s ON s.scholarshipID = ss.scholarshipID
                           LEFT JOIN campus_dynamics.acad_student st ON st.regno = ss.adm_no"
                         + whereClause + " ORDER BY ss.date_added DESC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                foreach (var p in parms) cmd.Parameters.Add(p);
                DataTable dt = new DataTable();
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }

                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", "attachment;filename=BursaryBeneficiaries_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.ContentEncoding = Encoding.UTF8;

                // Header
                Response.Write("ID,Reg No,Student Name,Bursary Scheme,Academic Year,Semester,Amount Offered,Status,TX Ref,Date Added,Notes\n");

                foreach (DataRow r in dt.Rows)
                {
                    Response.Write(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}\n",
                        r["stid"],
                        CsvSafe(r["adm_no"]),
                        CsvSafe(r["student_name"]),
                        CsvSafe(r["scholarshipName"]),
                        CsvSafe(r["scholarhipYear"]),
                        r["scholarhipTerm"],
                        r["amount_offered"],
                        CsvSafe(r["status"]),
                        r["transaction_ref"] == DBNull.Value ? "" : r["transaction_ref"].ToString(),
                        r["date_added"] == DBNull.Value ? "" : Convert.ToDateTime(r["date_added"]).ToString("yyyy-MM-dd"),
                        CsvSafe(r["notes"])));
                }

                Response.End();
            }
        }
    }

    // ====================================================================
    // Filter Events
    // ====================================================================
    protected void btnSearch_Click(object sender, EventArgs e) { }
    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlScheme.ClearSelection();
        ddlAcadYear.ClearSelection();
        ddlSemester.ClearSelection();
        LoadBeneficiaries();
    }
    protected void ddlScheme_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e) { }
    protected void ddlPageSize_Changed(object sender, EventArgs e) { }

    // ====================================================================
    // Template Helpers
    // ====================================================================

    protected string FormatAmt(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        try
        {
            double d = Convert.ToDouble(val);
            return "UGX " + d.ToString("N0");
        }
        catch { return val.ToString(); }
    }

    protected string FormatTxRef(object val)
    {
        if (val == null || val == DBNull.Value) return "<span style='color:#ccc;'>—</span>";
        string tid = val.ToString();
        return "<a href='FeesTransactions.aspx?tid=" + tid + "' target='_blank' style='color:#174DA4;font-weight:700;text-decoration:none;' title='Open transaction #" + tid + "'>#" + tid + "</a>";
    }

    protected string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        try { return Convert.ToDateTime(val).ToString("dd MMM yyyy"); }
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
        string s = val.ToString();
        if (s.Contains(",") || s.Contains("\"") || s.Contains("\n"))
            return "\"" + s.Replace("\"", "\"\"") + "\"";
        return s;
    }

    // ====================================================================
    // Plumbing
    // ====================================================================
    private void ShowToast(string message, bool success)
    {
        pnlToast.Visible = true;
        divToast.Attributes["class"] = success ? "fs-toast fs-toast--success" : "fs-toast fs-toast--error";
        divToast.InnerHtml = Server.HtmlEncode(message);
    }

    private void OpenModalAfterPostback(string modalId)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "reopenModal",
            "setTimeout(function(){ openModal('" + modalId + "'); },100);", true);
    }

    private static string JsEsc(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }

    // ====================================================================
    // BursaryManager — centralised, transactional Create / Update / Delete
    // Keeps scholarshipstudents + fin_studentfeestracking + fin_ledger in sync.
    // Every public method wraps its work in a MySqlTransaction so all three
    // tables are always written (or rolled back) together — no orphans.
    // ====================================================================
    private static class BursaryManager
    {
        public class Result
        {
            public bool   Success { get; set; }
            public string Message { get; set; }
            public long   TID     { get; set; }
        }

        // ----------------------------------------------------------------
        // Create — inserts beneficiary + payment transaction + ledger DR/CR
        // ----------------------------------------------------------------
        public static Result Create(MySqlConnection conn, string regNo, int schemeId,
            string schemeName, double amount, string acadYear, int semester, int itemCode, string notes)
        {
            var result = new Result();
            MySqlTransaction tx = conn.BeginTransaction();
            try
            {
                // 1. fin_studentfeestracking payment row
                long tid;
                using (MySqlCommand cmd = new MySqlCommand(
                    @"INSERT INTO fin_studentfeestracking
                        (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
                      VALUES (@r, @s, @y, @a, @ic, 'Payment', @d, @dt, 'Posted')", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@r",  regNo);
                    cmd.Parameters.AddWithValue("@s",  semester);
                    cmd.Parameters.AddWithValue("@y",  acadYear);
                    cmd.Parameters.AddWithValue("@a",  amount);
                    cmd.Parameters.AddWithValue("@ic", itemCode);
                    cmd.Parameters.AddWithValue("@d",  "Bursary: " + schemeName);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Now.ToString("yyyy-MM-dd"));
                    cmd.ExecuteNonQuery();
                    tid = cmd.LastInsertedId;
                }

                // 2. Ledger double-entry (DR asset + CR student folio)
                PostLedgerEntries(conn, tx, tid, regNo, amount, schemeName);

                // 3. scholarshipstudents beneficiary record
                using (MySqlCommand cmd = new MySqlCommand(
                    @"INSERT INTO scholarshipstudents
                        (adm_no, scholarshipID, scholarhipTerm, scholarhipYear,
                         amountDue, amount_offered, transaction_ref, status, notes)
                      VALUES (@r, @s, @t, @y, @amt, @amt, @tid, 'Approved', @notes)", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@r",     regNo);
                    cmd.Parameters.AddWithValue("@s",     schemeId);
                    cmd.Parameters.AddWithValue("@t",     semester);
                    cmd.Parameters.AddWithValue("@y",     acadYear);
                    cmd.Parameters.AddWithValue("@amt",   amount);
                    cmd.Parameters.AddWithValue("@tid",   tid);
                    cmd.Parameters.AddWithValue("@notes", string.IsNullOrEmpty(notes) ? (object)DBNull.Value : notes);
                    cmd.ExecuteNonQuery();
                }

                tx.Commit();
                result.Success = true;
                result.TID     = tid;
                result.Message = "Beneficiary added. TID #" + tid;
            }
            catch (Exception ex)
            {
                tx.Rollback();
                result.Success = false;
                result.Message = ex.Message;
            }
            return result;
        }

        // ----------------------------------------------------------------
        // Update — edits beneficiary; syncs transaction + ledger if amount changed
        // ----------------------------------------------------------------
        public static Result Update(MySqlConnection conn, int stid, int schemeId,
            string acadYear, int semester, double newAmount, string notes, int itemCode)
        {
            var result = new Result();
            MySqlTransaction tx = conn.BeginTransaction();
            try
            {
                // Load current state
                long? prevTID    = null;
                double prevAmount = 0;
                string prevAdmNo = "";
                string prevSchemeName = "";
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT ss.transaction_ref, ss.amount_offered, ss.adm_no,
                             IFNULL(s.scholarshipName,'') AS sname
                      FROM scholarshipstudents ss
                      LEFT JOIN scholarships s ON s.scholarshipID = ss.scholarshipID
                      WHERE ss.stid = @id", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@id", stid);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            tx.Rollback();
                            result.Success = false;
                            result.Message = "Beneficiary #" + stid + " not found.";
                            return result;
                        }
                        prevTID        = rdr["transaction_ref"] != DBNull.Value ? (long?)Convert.ToInt64(rdr["transaction_ref"]) : null;
                        prevAmount     = rdr["amount_offered"]  != DBNull.Value ? Convert.ToDouble(rdr["amount_offered"])        : 0;
                        prevAdmNo      = rdr["adm_no"].ToString();
                        prevSchemeName = rdr["sname"].ToString();
                    }
                }

                // Resolve new scheme name
                string newSchemeName = prevSchemeName;
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT IFNULL(scholarshipName,'') FROM scholarships WHERE scholarshipID=@s", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@s", schemeId);
                    object val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value) newSchemeName = val.ToString();
                }

                bool amountChanged = Math.Abs(newAmount - prevAmount) > 0.001;

                if (prevTID.HasValue && amountChanged)
                {
                    // Update payment row amount
                    using (MySqlCommand cmd = new MySqlCommand(
                        "UPDATE fin_studentfeestracking SET amount=@a, detail=@d WHERE TID=@tid AND trans_type='Payment'", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@a",   newAmount);
                        cmd.Parameters.AddWithValue("@d",   "Bursary: " + newSchemeName);
                        cmd.Parameters.AddWithValue("@tid", prevTID.Value);
                        cmd.ExecuteNonQuery();
                    }
                    // Replace ledger entries at new amount
                    DeleteLedgerEntries(conn, tx, prevTID.Value);
                    PostLedgerEntries(conn, tx, prevTID.Value, prevAdmNo, newAmount, newSchemeName);
                }
                else if (!prevTID.HasValue)
                {
                    // No transaction yet — create one now
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"INSERT INTO fin_studentfeestracking
                            (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
                          VALUES (@r, @s, @y, @a, @ic, 'Payment', @d, @dt, 'Posted')", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@r",  prevAdmNo);
                        cmd.Parameters.AddWithValue("@s",  semester);
                        cmd.Parameters.AddWithValue("@y",  acadYear);
                        cmd.Parameters.AddWithValue("@a",  newAmount);
                        cmd.Parameters.AddWithValue("@ic", itemCode);
                        cmd.Parameters.AddWithValue("@d",  "Bursary: " + newSchemeName);
                        cmd.Parameters.AddWithValue("@dt", DateTime.Now.ToString("yyyy-MM-dd"));
                        cmd.ExecuteNonQuery();
                        prevTID = cmd.LastInsertedId;
                    }
                    PostLedgerEntries(conn, tx, prevTID.Value, prevAdmNo, newAmount, newSchemeName);
                }

                // Update the beneficiary record
                using (MySqlCommand cmd = new MySqlCommand(
                    @"UPDATE scholarshipstudents SET
                        scholarshipID=@s, scholarhipTerm=@t, scholarhipYear=@y,
                        amountDue=@amt, amount_offered=@amt,
                        transaction_ref=@tid, notes=@notes
                      WHERE stid=@id", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@s",     schemeId);
                    cmd.Parameters.AddWithValue("@t",     semester);
                    cmd.Parameters.AddWithValue("@y",     acadYear);
                    cmd.Parameters.AddWithValue("@amt",   newAmount);
                    cmd.Parameters.AddWithValue("@tid",   prevTID.HasValue ? (object)prevTID.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@notes", string.IsNullOrEmpty(notes) ? (object)DBNull.Value : notes);
                    cmd.Parameters.AddWithValue("@id",    stid);
                    cmd.ExecuteNonQuery();
                }

                tx.Commit();
                result.Success = true;
                result.TID     = prevTID.HasValue ? prevTID.Value : 0;
                result.Message = "Beneficiary #" + stid + " updated."
                               + (amountChanged ? " Amount & ledger updated to UGX " + newAmount.ToString("N0") + "." : "");
            }
            catch (Exception ex)
            {
                tx.Rollback();
                result.Success = false;
                result.Message = ex.Message;
            }
            return result;
        }

        // ----------------------------------------------------------------
        // Delete — removes beneficiary + transaction + ledger atomically
        // ----------------------------------------------------------------
        public static Result Delete(MySqlConnection conn, int stid)
        {
            var result = new Result();
            MySqlTransaction tx = conn.BeginTransaction();
            try
            {
                // Read linked TID first
                long? tid = null;
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT transaction_ref FROM scholarshipstudents WHERE stid=@id", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@id", stid);
                    object val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value) tid = Convert.ToInt64(val);
                }

                // Delete the beneficiary
                int deleted;
                using (MySqlCommand cmd = new MySqlCommand(
                    "DELETE FROM scholarshipstudents WHERE stid=@id", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@id", stid);
                    deleted = cmd.ExecuteNonQuery();
                }

                if (deleted == 0)
                {
                    tx.Rollback();
                    result.Success = false;
                    result.Message = "Beneficiary not found.";
                    return result;
                }

                // Delete the payment transaction + ledger entries
                if (tid.HasValue)
                {
                    using (MySqlCommand cmd = new MySqlCommand(
                        "DELETE FROM fin_studentfeestracking WHERE TID=@tid AND trans_type='Payment'", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@tid", tid.Value);
                        cmd.ExecuteNonQuery();
                    }
                    DeleteLedgerEntries(conn, tx, tid.Value);
                    result.TID = tid.Value;
                }

                tx.Commit();
                result.Success = true;
                result.Message = "Beneficiary removed."
                               + (tid.HasValue ? " Fee transaction #" + tid.Value + " reversed." : "");
            }
            catch (Exception ex)
            {
                tx.Rollback();
                result.Success = false;
                result.Message = ex.Message;
            }
            return result;
        }

        // ----------------------------------------------------------------
        // GetOrCreateBillingItem — finds or creates 'Bursary/Scholarship' item
        // ----------------------------------------------------------------
        public static int GetOrCreateBillingItem(MySqlConnection conn)
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT ItemCode FROM academicbillingitems WHERE ItemName='Bursary/Scholarship' LIMIT 1", conn))
            {
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) return Convert.ToInt32(r);
            }
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT ItemCode FROM academicbillingitems WHERE ItemName LIKE '%Bursary%' OR ItemName LIKE '%Scholarship%' LIMIT 1", conn))
            {
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) return Convert.ToInt32(r);
            }
            using (MySqlCommand cmd = new MySqlCommand(
                "INSERT INTO academicbillingitems (ItemName, AccountCode, PriorityCode) VALUES ('Bursary/Scholarship','AC6099',1)", conn))
            {
                cmd.ExecuteNonQuery();
                return (int)cmd.LastInsertedId;
            }
        }

        // ----------------------------------------------------------------
        // PostLedgerEntries — DR on AC1302 (asset) + CR on student folio
        // ----------------------------------------------------------------
        private static void PostLedgerEntries(MySqlConnection conn, MySqlTransaction tx,
            long tid, string regNo, double amount, string schemeName)
        {
            const string sql = @"
                INSERT INTO fin_ledger
                    (accountcode, account_type, transactionType, transaction_amount, particulars,
                     voucherNo, transactionDate, teller, timeLog, folio,
                     journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                VALUES (@ac, @at, @tt, @amt, @part, @vno, @td, 'System', @tl, @fo, '-', 'UGX', @amt, 0, 1, @amt)";

            string today = DateTime.Now.ToString("yyyy-MM-dd");

            // DR — bursary disbursed (asset side)
            using (MySqlCommand cmd = new MySqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@ac",   "AC1302");
                cmd.Parameters.AddWithValue("@at",   "Chart Account");
                cmd.Parameters.AddWithValue("@tt",   "DR");
                cmd.Parameters.AddWithValue("@amt",  amount);
                cmd.Parameters.AddWithValue("@part", "Bursary disbursed: " + schemeName + " [" + regNo + "]");
                cmd.Parameters.AddWithValue("@vno",  tid);
                cmd.Parameters.AddWithValue("@td",   today);
                cmd.Parameters.AddWithValue("@tl",   DateTime.Now);
                cmd.Parameters.AddWithValue("@fo",   regNo);
                cmd.ExecuteNonQuery();
            }

            // CR — student balance reduced
            using (MySqlCommand cmd = new MySqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@ac",   regNo);
                cmd.Parameters.AddWithValue("@at",   "BursaryFees");
                cmd.Parameters.AddWithValue("@tt",   "CR");
                cmd.Parameters.AddWithValue("@amt",  amount);
                cmd.Parameters.AddWithValue("@part", "Bursary: " + schemeName);
                cmd.Parameters.AddWithValue("@vno",  tid);
                cmd.Parameters.AddWithValue("@td",   today);
                cmd.Parameters.AddWithValue("@tl",   DateTime.Now);
                cmd.Parameters.AddWithValue("@fo",   regNo);
                cmd.ExecuteNonQuery();
            }
        }

        // ----------------------------------------------------------------
        // DeleteLedgerEntries — removes both DR and CR rows for a voucherNo
        // ----------------------------------------------------------------
        private static void DeleteLedgerEntries(MySqlConnection conn, MySqlTransaction tx, long tid)
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "DELETE FROM fin_ledger WHERE voucherNo=@vno", conn, tx))
            {
                cmd.Parameters.AddWithValue("@vno", tid);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
