using System;
using System.Data;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_BursarySchemes : System.Web.UI.Page
{
    private string AcctConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureSchemeTypeColumns();

        txtAddAmt.Attributes["type"] = "number";
        txtAddAmt.Attributes["min"] = "0";
        txtAddAmt.Attributes["step"] = "1";
        txtAddPct.Attributes["type"] = "number";
        txtAddPct.Attributes["min"] = "0";
        txtAddPct.Attributes["max"] = "100";
        txtAddPct.Attributes["step"] = "0.01";
        txtEditAmt.Attributes["type"] = "number";
        txtEditAmt.Attributes["min"] = "0";
        txtEditAmt.Attributes["step"] = "1";
        txtEditPct.Attributes["type"] = "number";
        txtEditPct.Attributes["min"] = "0";
        txtEditPct.Attributes["max"] = "100";
        txtEditPct.Attributes["step"] = "0.01";

        RestorePostedValue(ddlStatus);
        RestorePostedValue(ddlAddStatus);
        RestorePostedValue(ddlAddType);
        RestorePostedValue(ddlEditStatus);
        RestorePostedValue(ddlEditType);

        LoadSchemes();
    }

    // ====================================================================
    // Migration — add scheme_type + scheme_value columns if missing
    // ====================================================================
    private static bool _schemaChecked;
    private void EnsureSchemeTypeColumns()
    {
        if (_schemaChecked) return;
        _schemaChecked = true;
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            DataTable cols = conn.GetSchema("Columns", new string[] { null, null, "scholarships", "scheme_type" });
            if (cols.Rows.Count == 0)
            {
                using (MySqlCommand cmd = new MySqlCommand(
                    @"ALTER TABLE scholarships
                      ADD COLUMN scheme_type VARCHAR(12) NOT NULL DEFAULT 'FIXED' AFTER bursary_amount,
                      ADD COLUMN scheme_value DECIMAL(12,2) NULL AFTER scheme_type", conn))
                { cmd.ExecuteNonQuery(); }
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
    // Load Data
    // ====================================================================
    private void LoadSchemes()
    {
        string search = (txtSearch != null ? txtSearch.Text.Trim() : "");
        string statusFilter = ddlStatus.SelectedValue;

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Stats
            using (MySqlCommand cmdStats = new MySqlCommand(
                @"SELECT 
                    COUNT(*) AS total,
                    SUM(CASE WHEN s.status='Active' THEN 1 ELSE 0 END) AS active_count,
                    SUM(CASE WHEN s.status='Inactive' THEN 1 ELSE 0 END) AS inactive_count,
                    (SELECT COUNT(*) FROM scholarshipstudents) AS beneficiary_count
                  FROM scholarships s", conn))
            {
                using (MySqlDataReader rdr = cmdStats.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litTotalSchemes.Text = rdr["total"].ToString();
                        litActiveSchemes.Text = rdr["active_count"].ToString();
                        litInactiveSchemes.Text = rdr["inactive_count"].ToString();
                        litTotalBeneficiaries.Text = rdr["beneficiary_count"].ToString();
                    }
                }
            }

            // Build WHERE
            var where = new System.Collections.Generic.List<string>();
            var parms = new System.Collections.Generic.List<MySqlParameter>();

            if (!string.IsNullOrEmpty(statusFilter))
            {
                where.Add("s.status = @status");
                parms.Add(new MySqlParameter("@status", statusFilter));
            }
            if (!string.IsNullOrEmpty(search))
            {
                where.Add("(s.scholarshipName LIKE @search OR s.scholarshipdetails LIKE @search)");
                parms.Add(new MySqlParameter("@search", "%" + search + "%"));
            }

            string whereClause = where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";

            string sql = @"SELECT s.scholarshipID, s.scholarshipName, s.scholarshipdetails, 
                                  s.bursary_amount, s.scheme_type, s.scheme_value,
                                  s.status, s.created_at, s.updated_at,
                                  IFNULL(bc.cnt, 0) AS beneficiary_count
                           FROM scholarships s
                           LEFT JOIN (SELECT scholarshipID, COUNT(*) AS cnt FROM scholarshipstudents GROUP BY scholarshipID) bc 
                                ON bc.scholarshipID = s.scholarshipID"
                         + whereClause + " ORDER BY s.scholarshipName ASC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                foreach (var p in parms) cmd.Parameters.Add(p);

                DataTable dt = new DataTable();
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                gvSchemes.DataSource = dt;
                gvSchemes.DataBind();

                lblRecordCount.Text = dt.Rows.Count + " record" + (dt.Rows.Count != 1 ? "s" : "");
                litFooter.Text = string.Format("Showing <strong>{0}</strong> bursary scheme{1}", dt.Rows.Count, dt.Rows.Count != 1 ? "s" : "");
            }
        }
    }

    // ====================================================================
    // Create Scheme
    // ====================================================================
    protected void btnSaveScheme_Click(object sender, EventArgs e)
    {
        RestorePostedValue(ddlAddStatus);
        RestorePostedValue(ddlAddType);

        string name = txtAddName.Text.Trim();
        string details = txtAddDetails.Text.Trim();
        string schemeType = ddlAddType.SelectedValue; // FIXED, PERCENTAGE, CUSTOM
        string amtStr = txtAddAmt.Text.Trim();
        string pctStr = txtAddPct.Text.Trim();
        string status = ddlAddStatus.SelectedValue;

        if (string.IsNullOrEmpty(name))
        { ShowToast("Scheme Name is required.", false); OpenModalAfterPostback("modal-add-scheme"); return; }
        if (string.IsNullOrEmpty(details))
        { ShowToast("Details / Description is required.", false); OpenModalAfterPostback("modal-add-scheme"); return; }

        if (schemeType != "FIXED" && schemeType != "PERCENTAGE" && schemeType != "CUSTOM")
            schemeType = "FIXED";

        double amt = 0;
        double pct = 0;

        if (schemeType == "FIXED")
        {
            if (string.IsNullOrEmpty(amtStr))
            { ShowToast("Bursary Amount is required for Fixed type.", false); OpenModalAfterPostback("modal-add-scheme"); return; }
            if (!double.TryParse(amtStr, out amt) || amt < 0)
            { ShowToast("Amount must be a positive number.", false); OpenModalAfterPostback("modal-add-scheme"); return; }
        }
        else if (schemeType == "PERCENTAGE")
        {
            if (string.IsNullOrEmpty(pctStr))
            { ShowToast("Percentage value is required.", false); OpenModalAfterPostback("modal-add-scheme"); return; }
            if (!double.TryParse(pctStr, out pct) || pct <= 0 || pct > 100)
            { ShowToast("Percentage must be between 0.01 and 100.", false); OpenModalAfterPostback("modal-add-scheme"); return; }
        }
        // CUSTOM: no amount or percentage needed at scheme level

        if (status != "Active" && status != "Inactive") status = "Active";

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                string sql = @"INSERT INTO scholarships (scholarshipName, scholarshipdetails, bursary_amount, scheme_type, scheme_value, percentagePay, status)
                               VALUES (@name, @details, @amt, @stype, @sval, @pctPay, @status)";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@details", details);
                    cmd.Parameters.AddWithValue("@amt", schemeType == "FIXED" ? amt : 0);
                    cmd.Parameters.AddWithValue("@stype", schemeType);
                    cmd.Parameters.AddWithValue("@sval", schemeType == "FIXED" ? (object)amt : schemeType == "PERCENTAGE" ? (object)pct : DBNull.Value);
                    cmd.Parameters.AddWithValue("@pctPay", schemeType == "PERCENTAGE" ? pct : 0);
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.ExecuteNonQuery();
                }
            }
            txtAddName.Text = ""; txtAddDetails.Text = ""; txtAddAmt.Text = ""; txtAddPct.Text = "";
            ShowToast("Bursary scheme '" + Server.HtmlEncode(name) + "' created successfully.", true);
            LoadSchemes();
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
            OpenModalAfterPostback("modal-add-scheme");
        }
    }

    // ====================================================================
    // Edit Scheme
    // ====================================================================
    protected void btnEditScheme_Click(object sender, EventArgs e)
    {
        RestorePostedValue(ddlEditStatus);
        RestorePostedValue(ddlEditType);

        string idStr = hfEditID.Value.Trim();
        int id;
        if (!int.TryParse(idStr, out id) || id <= 0)
        { ShowToast("Invalid scheme ID.", false); return; }

        string name = txtEditName.Text.Trim();
        string details = txtEditDetails.Text.Trim();
        string schemeType = ddlEditType.SelectedValue;
        string amtStr = txtEditAmt.Text.Trim();
        string pctStr = txtEditPct.Text.Trim();
        string status = ddlEditStatus.SelectedValue;

        if (string.IsNullOrEmpty(name))
        { ShowToast("Scheme Name is required.", false); OpenModalAfterPostback("modal-edit-scheme"); return; }
        if (string.IsNullOrEmpty(details))
        { ShowToast("Details is required.", false); OpenModalAfterPostback("modal-edit-scheme"); return; }

        if (schemeType != "FIXED" && schemeType != "PERCENTAGE" && schemeType != "CUSTOM")
            schemeType = "FIXED";

        double amt = 0;
        double pct = 0;

        if (schemeType == "FIXED")
        {
            if (string.IsNullOrEmpty(amtStr))
            { ShowToast("Bursary Amount is required for Fixed type.", false); OpenModalAfterPostback("modal-edit-scheme"); return; }
            if (!double.TryParse(amtStr, out amt) || amt < 0)
            { ShowToast("Amount must be a positive number.", false); OpenModalAfterPostback("modal-edit-scheme"); return; }
        }
        else if (schemeType == "PERCENTAGE")
        {
            if (string.IsNullOrEmpty(pctStr))
            { ShowToast("Percentage value is required.", false); OpenModalAfterPostback("modal-edit-scheme"); return; }
            if (!double.TryParse(pctStr, out pct) || pct <= 0 || pct > 100)
            { ShowToast("Percentage must be between 0.01 and 100.", false); OpenModalAfterPostback("modal-edit-scheme"); return; }
        }

        if (status != "Active" && status != "Inactive") status = "Active";

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                string sql = @"UPDATE scholarships SET scholarshipName=@name, scholarshipdetails=@details, 
                               bursary_amount=@amt, scheme_type=@stype, scheme_value=@sval,
                               percentagePay=@pctPay, status=@status WHERE scholarshipID=@id";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@details", details);
                    cmd.Parameters.AddWithValue("@amt", schemeType == "FIXED" ? amt : 0);
                    cmd.Parameters.AddWithValue("@stype", schemeType);
                    cmd.Parameters.AddWithValue("@sval", schemeType == "FIXED" ? (object)amt : schemeType == "PERCENTAGE" ? (object)pct : DBNull.Value);
                    cmd.Parameters.AddWithValue("@pctPay", schemeType == "PERCENTAGE" ? pct : 0);
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.Parameters.AddWithValue("@id", id);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                        ShowToast("Scheme #" + id + " updated successfully.", true);
                    else
                        ShowToast("Scheme #" + id + " was not found.", false);
                }
            }
            LoadSchemes();
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
            OpenModalAfterPostback("modal-edit-scheme");
        }
    }

    // ====================================================================
    // Delete Scheme
    // ====================================================================
    protected void btnDeleteScheme_Click(object sender, EventArgs e)
    {
        string idStr = hfDeleteID.Value.Trim();
        int id;
        if (!int.TryParse(idStr, out id) || id <= 0)
        { ShowToast("Invalid scheme ID.", false); return; }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Check for linked beneficiaries
                using (MySqlCommand chk = new MySqlCommand("SELECT COUNT(*) FROM scholarshipstudents WHERE scholarshipID=@id", conn))
                {
                    chk.Parameters.AddWithValue("@id", id);
                    long cnt = Convert.ToInt64(chk.ExecuteScalar());
                    if (cnt > 0)
                    {
                        ShowToast("Cannot delete — this scheme has " + cnt + " beneficiar" + (cnt == 1 ? "y" : "ies") + " linked to it. Remove beneficiaries first.", false);
                        return;
                    }
                }

                using (MySqlCommand cmd = new MySqlCommand("DELETE FROM scholarships WHERE scholarshipID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                        ShowToast("Bursary scheme deleted.", true);
                    else
                        ShowToast("Scheme not found.", false);
                }
            }
            LoadSchemes();
        }
        catch (Exception ex)
        {
            ShowToast("Error: " + Server.HtmlEncode(ex.Message), false);
        }
    }

    // ====================================================================
    // Filter Events
    // ====================================================================
    protected void btnSearch_Click(object sender, EventArgs e) { /* reload happens in Page_Load */ }
    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlStatus.ClearSelection();
        LoadSchemes();
    }
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e) { /* reload happens in Page_Load */ }

    // ====================================================================
    // Template Helpers
    // ====================================================================
    protected string GetSchemeTypeBadge(object val)
    {
        string t = (val != null && val != DBNull.Value) ? val.ToString().ToUpper() : "FIXED";
        if (t == "PERCENTAGE") return "<span class='bs-badge bs-badge--pct'>% Percentage</span>";
        if (t == "CUSTOM")     return "<span class='bs-badge bs-badge--custom'>Custom</span>";
        return "<span class='bs-badge bs-badge--fixed'>Fixed</span>";
    }

    protected string GetSchemeValueDisplay(object typeObj, object amtObj, object valObj)
    {
        string t = (typeObj != null && typeObj != DBNull.Value) ? typeObj.ToString().ToUpper() : "FIXED";
        if (t == "PERCENTAGE")
        {
            double pct = 0;
            if (valObj != null && valObj != DBNull.Value) double.TryParse(valObj.ToString(), out pct);
            return pct.ToString("0.##") + "% of total fees";
        }
        if (t == "CUSTOM")
            return "<span style='color:#888;font-style:italic;'>Per beneficiary</span>";
        // FIXED
        double amt = 0;
        if (amtObj != null && amtObj != DBNull.Value) double.TryParse(amtObj.ToString(), out amt);
        return "<span class='bs-amount'><span class='bs-amount__currency'>UGX</span>" + amt.ToString("N0") + "</span>";
    }

    protected string GetStatusClass(object val)
    {
        if (val == null) return "";
        string s = val.ToString();
        if (s == "Active") return "bs-badge--active";
        if (s == "Inactive") return "bs-badge--inactive";
        return "";
    }

    protected string FormatAmount(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        try
        {
            double d = Convert.ToDouble(val);
            return d.ToString("N0");
        }
        catch { return val.ToString(); }
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
}
