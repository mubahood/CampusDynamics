using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Data;
using DevExpress.Web;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_StudentsIDCards : System.Web.UI.Page
{
    private string connStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAcadYears();
            LoadProgrammes();
            BindGrid();
            UpdateStats();
            UpdateHeaderDisplay();
        }
    }

    #region Data Binding

    private void LoadAcadYears()
    {
        ddlAcadYear.Items.Clear();
        
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 2; i >= currentYear - 10; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }

        // Try to set current year
        string currentAcadYear = GetCurrentAcadYear();
        ListItem li = ddlAcadYear.Items.FindByValue(currentAcadYear);
        if (li != null) li.Selected = true;
    }

    private string GetCurrentAcadYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        
        // If we're in the second half of the year, the academic year is current/next
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }

    private void LoadProgrammes()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
            MySqlCommand cmd = new MySqlCommand(sql, conn);
            MySqlDataReader dr = cmd.ExecuteReader();

            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
            while (dr.Read())
            {
                ddlProgramme.Items.Add(new ListItem(
                    dr["progcode"].ToString() + " - " + dr["progname"].ToString(),
                    dr["progcode"].ToString()
                ));
            }
        }
    }

    private void BindGrid()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = @"SELECT c.ID, c.reg_no, 
                           CONCAT(s.firstname, ' ', COALESCE(s.othername, '')) AS student_name,
                           s.progid as progcode, c.stud_intake, c.card_status, c.reg_status, c.residence_stat,
                           c.expiry_date, c.created_by, c.date_created
                           FROM acad_student_cards c
                           LEFT JOIN acad_student s ON c.reg_no = s.regno
                           WHERE c.acadyear = @acadyear AND c.semester = @semester AND c.card_type = @cardType";

            List<MySqlParameter> parms = new List<MySqlParameter>();
            parms.Add(new MySqlParameter("@acadyear", ddlAcadYear.SelectedValue));
            parms.Add(new MySqlParameter("@semester", ddlSemester.SelectedValue));
            parms.Add(new MySqlParameter("@cardType", ddlCardType.SelectedValue));

            if (!string.IsNullOrEmpty(ddlCardStatus.SelectedValue))
            {
                sql += " AND c.card_status = @cardStatus";
                parms.Add(new MySqlParameter("@cardStatus", ddlCardStatus.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                sql += " AND s.progid = @progcode";
                parms.Add(new MySqlParameter("@progcode", ddlProgramme.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlIntake.SelectedValue))
            {
                sql += " AND c.stud_intake = @intake";
                parms.Add(new MySqlParameter("@intake", ddlIntake.SelectedValue));
            }

            sql += " ORDER BY s.firstname, s.othername";

            MySqlCommand cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddRange(parms.ToArray());

            DataTable dt = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            da.Fill(dt);

            gvCards.DataSource = dt;
            gvCards.DataBind();
        }
    }

    private void UpdateStats()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = @"SELECT card_status, COUNT(*) as cnt FROM acad_student_cards 
                           WHERE acadyear = @acadyear AND semester = @semester AND card_type = @cardType
                           GROUP BY card_status";

            MySqlCommand cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@acadyear", ddlAcadYear.SelectedValue);
            cmd.Parameters.AddWithValue("@semester", ddlSemester.SelectedValue);
            cmd.Parameters.AddWithValue("@cardType", ddlCardType.SelectedValue);

            MySqlDataReader dr = cmd.ExecuteReader();

            int pending = 0, ready = 0, printed = 0, taken = 0;

            while (dr.Read())
            {
                string status = dr["card_status"].ToString();
                int cnt = Convert.ToInt32(dr["cnt"]);

                switch (status.ToUpper())
                {
                    case "PENDING": pending = cnt; break;
                    case "READY": ready = cnt; break;
                    case "PRINTED": printed = cnt; break;
                    case "TAKEN": taken = cnt; break;
                }
            }

            litPending.Text = pending.ToString("N0");
            litReady.Text = ready.ToString("N0");
            litPrinted.Text = printed.ToString("N0");
            litTaken.Text = taken.ToString("N0");
            litTotal.Text = (pending + ready + printed + taken).ToString("N0");
        }
    }

    private void UpdateHeaderDisplay()
    {
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
        litCardTypeDisplay.Text = ddlCardType.SelectedItem.Text;
    }

    #endregion

    #region Filter Events

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
        UpdateStats();
        UpdateHeaderDisplay();
    }

    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
        UpdateStats();
        UpdateHeaderDisplay();
    }

    protected void ddlCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
        UpdateStats();
        UpdateHeaderDisplay();
    }

    protected void ddlCardStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void ddlIntake_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    #endregion

    #region Generate Cards

    protected void btnGenerateCards_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlGenIntake.SelectedValue))
        {
            ShowMessage("Please select an intake.");
            return;
        }

        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;
        string cardType = ddlCardType.SelectedValue;
        string intake = ddlGenIntake.SelectedValue;
        string createdBy = Session["username"] != null ? Session["username"].ToString() : "SYSTEM";

        int inserted = 0;
        int skipped = 0;

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            // Get students for the selected intake that don't have a card yet
            string sqlStudents = @"SELECT s.regno, r.residence_status, r.regstatus
                                   FROM acad_student s
                                   LEFT JOIN acad_registration r ON s.regno = r.regno 
                                       AND r.acad_year = @acadyear AND r.semester = @semester
                                   WHERE s.intake = @intake AND (s.stud_status = 'Active' OR s.new_status = 'Active')
                                   AND NOT EXISTS (
                                       SELECT 1 FROM acad_student_cards c 
                                       WHERE c.reg_no = s.regno 
                                       AND c.acadyear = @acadyear AND c.semester = @semester AND c.card_type = @cardType
                                   )";

            MySqlCommand cmdStudents = new MySqlCommand(sqlStudents, conn);
            cmdStudents.Parameters.AddWithValue("@acadyear", acadYear);
            cmdStudents.Parameters.AddWithValue("@semester", semester);
            cmdStudents.Parameters.AddWithValue("@cardType", cardType);
            cmdStudents.Parameters.AddWithValue("@intake", intake);

            DataTable dtStudents = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmdStudents);
            da.Fill(dtStudents);

            // Insert cards for each student
            string sqlInsert = @"INSERT INTO acad_student_cards 
                                (reg_no, acadyear, semester, card_type, card_status, created_by, residence_stat, reg_status, date_created, stud_intake)
                                VALUES (@reg_no, @acadyear, @semester, @cardType, 'PENDING', @createdBy, @residence, @regStatus, NOW(), @intake)";

            foreach (DataRow row in dtStudents.Rows)
            {
                try
                {
                    MySqlCommand cmdInsert = new MySqlCommand(sqlInsert, conn);
                    cmdInsert.Parameters.AddWithValue("@reg_no", row["regno"]);
                    cmdInsert.Parameters.AddWithValue("@acadyear", acadYear);
                    cmdInsert.Parameters.AddWithValue("@semester", semester);
                    cmdInsert.Parameters.AddWithValue("@cardType", cardType);
                    cmdInsert.Parameters.AddWithValue("@createdBy", createdBy);
                    cmdInsert.Parameters.AddWithValue("@residence", row["residence_status"] ?? "");
                    cmdInsert.Parameters.AddWithValue("@regStatus", row["regstatus"] ?? "UNREGISTERED");
                    cmdInsert.Parameters.AddWithValue("@intake", intake);
                    cmdInsert.ExecuteNonQuery();
                    inserted++;
                }
                catch
                {
                    skipped++;
                }
            }
        }

        BindGrid();
        UpdateStats();
        ShowMessage(string.Format("Card generation complete.<br/>Generated: {0}<br/>Skipped: {1}", inserted, skipped));
    }

    #endregion

    #region Update Status

    protected void btnUpdateStatus_Click(object sender, EventArgs e)
    {
        List<object> keys = gvCards.GetSelectedFieldValues("ID");
        if (keys.Count == 0)
        {
            ShowMessage("Please select at least one card.");
            return;
        }

        string newStatus = ddlNewStatus.SelectedValue;
        int updated = UpdateCardStatus(keys, newStatus);

        gvCards.Selection.UnselectAll();
        BindGrid();
        UpdateStats();
        ShowMessage(string.Format("Updated {0} card(s) to '{1}' status.", updated, newStatus));
    }

    protected void btnReady_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = Convert.ToInt32(btn.CommandArgument);
        UpdateSingleCardStatus(id, "READY");
        BindGrid();
        UpdateStats();
    }

    protected void btnPrinted_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = Convert.ToInt32(btn.CommandArgument);
        UpdateSingleCardStatus(id, "PRINTED");
        BindGrid();
        UpdateStats();
    }

    protected void btnTaken_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = Convert.ToInt32(btn.CommandArgument);
        UpdateSingleCardStatus(id, "TAKEN");
        BindGrid();
        UpdateStats();
    }

    private int UpdateCardStatus(List<object> ids, string newStatus)
    {
        int updated = 0;
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            foreach (object id in ids)
            {
                string sql = "UPDATE acad_student_cards SET card_status = @status WHERE ID = @id";
                MySqlCommand cmd = new MySqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@status", newStatus);
                cmd.Parameters.AddWithValue("@id", id);
                updated += cmd.ExecuteNonQuery();
            }
        }
        return updated;
    }

    private void UpdateSingleCardStatus(int id, string newStatus)
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = "UPDATE acad_student_cards SET card_status = @status WHERE ID = @id";
            MySqlCommand cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@status", newStatus);
            cmd.Parameters.AddWithValue("@id", id);
            cmd.ExecuteNonQuery();
        }
    }

    #endregion

    #region Batch Operations

    protected void btnBatchReady_Click(object sender, EventArgs e)
    {
        List<object> keys = gvCards.GetSelectedFieldValues("ID");
        if (keys.Count == 0) return;

        int updated = UpdateCardStatus(keys, "READY");
        gvCards.Selection.UnselectAll();
        BindGrid();
        UpdateStats();
        ShowMessage(string.Format("Marked {0} card(s) as Ready.", updated));
    }

    protected void btnBatchPrinted_Click(object sender, EventArgs e)
    {
        List<object> keys = gvCards.GetSelectedFieldValues("ID");
        if (keys.Count == 0) return;

        int updated = UpdateCardStatus(keys, "PRINTED");
        gvCards.Selection.UnselectAll();
        BindGrid();
        UpdateStats();
        ShowMessage(string.Format("Marked {0} card(s) as Printed.", updated));
    }

    protected void btnBatchTaken_Click(object sender, EventArgs e)
    {
        List<object> keys = gvCards.GetSelectedFieldValues("ID");
        if (keys.Count == 0) return;

        int updated = UpdateCardStatus(keys, "TAKEN");
        gvCards.Selection.UnselectAll();
        BindGrid();
        UpdateStats();
        ShowMessage(string.Format("Marked {0} card(s) as Taken.", updated));
    }

    protected void btnBatchDelete_Click(object sender, EventArgs e)
    {
        List<object> keys = gvCards.GetSelectedFieldValues("ID");
        if (keys.Count == 0) return;

        int deleted = 0;
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            foreach (object id in keys)
            {
                string sql = "DELETE FROM acad_student_cards WHERE ID = @id";
                MySqlCommand cmd = new MySqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", id);
                deleted += cmd.ExecuteNonQuery();
            }
        }

        gvCards.Selection.UnselectAll();
        BindGrid();
        UpdateStats();
        ShowMessage(string.Format("Deleted {0} card record(s).", deleted));
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        BindGrid();
        UpdateStats();
    }

    #endregion

    #region Single Delete

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = Convert.ToInt32(btn.CommandArgument);

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = "DELETE FROM acad_student_cards WHERE ID = @id";
            MySqlCommand cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@id", id);
            cmd.ExecuteNonQuery();
        }

        BindGrid();
        UpdateStats();
    }

    #endregion

    #region Helpers

    protected string GetStatusClass(string status)
    {
        switch (status.ToUpper())
        {
            case "PENDING": return "pending";
            case "READY": return "ready";
            case "PRINTED": return "printed";
            case "TAKEN": return "taken";
            default: return "pending";
        }
    }

    protected string GetRegStatusClass(string status)
    {
        if (status.ToUpper() == "REGISTERED") return "registered";
        return "unregistered";
    }

    protected void gvCards_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
    {
        // Optional cell customization
    }

    private void ShowMessage(string message)
    {
        litMessage.Text = message;
        popMessage.ShowOnPageLoad = true;
    }

    #endregion
}
