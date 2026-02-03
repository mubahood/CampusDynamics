using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Data;
using DevExpress.Web;
using DevExpress.Export;
using DevExpress.XtraPrinting;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_StudentDocuments : System.Web.UI.Page
{
    private string connStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadProgrammes();
            LoadEntryYears();
            BindGrid();
            UpdateStats();
        }
    }

    #region Data Binding

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

    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- Entry Year --", ""));
        
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 15; i--)
        {
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }
    }

    private void BindGrid()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            
            // Query students with document count from stddoc table
            string sql = @"SELECT s.regno, 
                           CONCAT(s.firstname, ' ', COALESCE(s.othername, '')) AS student_name,
                           s.progid, s.entryyear, s.intake, s.studPhone, s.email,
                           COALESCE(d.doc_count, 0) AS doc_count,
                           CASE 
                               WHEN COALESCE(d.doc_count, 0) >= 3 THEN 'COMPLETE'
                               WHEN COALESCE(d.doc_count, 0) > 0 THEN 'PARTIAL'
                               ELSE 'MISSING'
                           END AS doc_status
                           FROM acad_student s
                           LEFT JOIN (
                               SELECT docbioid, COUNT(*) AS doc_count 
                               FROM stddoc 
                               GROUP BY docbioid
                           ) d ON s.regno = d.docbioid
                           WHERE (s.stud_status = 'Active' OR s.new_status = 'Active')";

            List<MySqlParameter> parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                sql += " AND s.progid = @progid";
                parms.Add(new MySqlParameter("@progid", ddlProgramme.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
            {
                sql += " AND s.entryyear = @entryyear";
                parms.Add(new MySqlParameter("@entryyear", int.Parse(ddlEntryYear.SelectedValue)));
            }

            if (!string.IsNullOrEmpty(ddlIntake.SelectedValue))
            {
                sql += " AND s.intake = @intake";
                parms.Add(new MySqlParameter("@intake", ddlIntake.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlDocStatus.SelectedValue))
            {
                switch (ddlDocStatus.SelectedValue)
                {
                    case "COMPLETE":
                        sql += " HAVING doc_count >= 3";
                        break;
                    case "PARTIAL":
                        sql += " HAVING doc_count > 0 AND doc_count < 3";
                        break;
                    case "MISSING":
                        sql += " HAVING doc_count = 0";
                        break;
                }
            }

            sql += " ORDER BY s.firstname, s.othername";

            MySqlCommand cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddRange(parms.ToArray());

            DataTable dt = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            da.Fill(dt);

            gvDocuments.DataSource = dt;
            gvDocuments.DataBind();
        }
    }

    private void UpdateStats()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            
            // Total active students
            string sqlTotal = @"SELECT COUNT(*) FROM acad_student WHERE (stud_status = 'Active' OR new_status = 'Active')";
            MySqlCommand cmdTotal = new MySqlCommand(sqlTotal, conn);
            int total = Convert.ToInt32(cmdTotal.ExecuteScalar());
            litTotalStudents.Text = total.ToString("N0");

            // Students with complete docs (3+)
            string sqlComplete = @"SELECT COUNT(DISTINCT s.regno) FROM acad_student s
                                   INNER JOIN stddoc d ON s.regno = d.docbioid
                                   WHERE (s.stud_status = 'Active' OR s.new_status = 'Active')
                                   GROUP BY s.regno HAVING COUNT(*) >= 3";
            MySqlCommand cmdComplete = new MySqlCommand(sqlComplete, conn);
            
            int complete = 0;
            try
            {
                DataTable dtComplete = new DataTable();
                MySqlDataAdapter daComplete = new MySqlDataAdapter(cmdComplete);
                daComplete.Fill(dtComplete);
                complete = dtComplete.Rows.Count;
            }
            catch { }
            litComplete.Text = complete.ToString("N0");

            // Students with partial docs (1-2)
            string sqlPartial = @"SELECT COUNT(DISTINCT s.regno) FROM acad_student s
                                  INNER JOIN stddoc d ON s.regno = d.docbioid
                                  WHERE (s.stud_status = 'Active' OR s.new_status = 'Active')
                                  GROUP BY s.regno HAVING COUNT(*) > 0 AND COUNT(*) < 3";
            MySqlCommand cmdPartial = new MySqlCommand(sqlPartial, conn);
            
            int partial = 0;
            try
            {
                DataTable dtPartial = new DataTable();
                MySqlDataAdapter daPartial = new MySqlDataAdapter(cmdPartial);
                daPartial.Fill(dtPartial);
                partial = dtPartial.Rows.Count;
            }
            catch { }
            litPartial.Text = partial.ToString("N0");

            // Students with no docs
            int missing = total - complete - partial;
            litMissing.Text = missing.ToString("N0");
        }
    }

    #endregion

    #region Filter Events

    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void ddlEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void ddlIntake_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void ddlDocStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    #endregion

    #region Actions

    protected void btnViewDocs_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        string regno = btn.CommandArgument;

        litViewRegNo.Text = regno;

        // Get student name
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            
            string sqlName = "SELECT CONCAT(firstname, ' ', COALESCE(othername, '')) AS student_name FROM acad_student WHERE regno = @regno";
            MySqlCommand cmdName = new MySqlCommand(sqlName, conn);
            cmdName.Parameters.AddWithValue("@regno", regno);
            object result = cmdName.ExecuteScalar();
            litViewName.Text = result != null ? result.ToString() : "";

            // Get documents
            string sqlDocs = "SELECT doccode, docfilename, docfiletype, docdate, docuser FROM stddoc WHERE docbioid = @regno";
            MySqlCommand cmdDocs = new MySqlCommand(sqlDocs, conn);
            cmdDocs.Parameters.AddWithValue("@regno", regno);

            DataTable dt = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmdDocs);
            da.Fill(dt);

            gvStudentDocs.DataSource = dt;
            gvStudentDocs.DataBind();
        }

        popViewDocs.ShowOnPageLoad = true;
    }

    protected void btnUploadDoc_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        hfUploadRegNo.Value = btn.CommandArgument;
        popUpload.ShowOnPageLoad = true;
    }

    protected void btnViewProfile_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        string regno = btn.CommandArgument;
        Response.Redirect("~/COOPERP/NewScreens/NewStudentInfo.aspx?regno=" + regno);
    }

    protected void btnDoUpload_Click(object sender, EventArgs e)
    {
        if (!uploadFile.HasFile)
        {
            ShowMessage("Please select a file to upload.");
            return;
        }

        string regno = hfUploadRegNo.Value;
        string docCode = ddlDocType.SelectedValue;
        string fileName = uploadFile.FileName;
        string fileType = System.IO.Path.GetExtension(fileName);
        byte[] fileData = uploadFile.FileBytes;
        string username = Session["username"] != null ? Session["username"].ToString() : "SYSTEM";

        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            // Check if document already exists
            string sqlCheck = "SELECT COUNT(*) FROM stddoc WHERE docbioid = @regno AND doccode = @doccode";
            MySqlCommand cmdCheck = new MySqlCommand(sqlCheck, conn);
            cmdCheck.Parameters.AddWithValue("@regno", regno);
            cmdCheck.Parameters.AddWithValue("@doccode", docCode);
            int exists = Convert.ToInt32(cmdCheck.ExecuteScalar());

            if (exists > 0)
            {
                // Update existing
                string sqlUpdate = @"UPDATE stddoc SET docfilename = @filename, docfiletype = @filetype, 
                                     docblob = @filedata, docdate = @docdate, docuser = @docuser 
                                     WHERE docbioid = @regno AND doccode = @doccode";
                MySqlCommand cmdUpdate = new MySqlCommand(sqlUpdate, conn);
                cmdUpdate.Parameters.AddWithValue("@filename", fileName);
                cmdUpdate.Parameters.AddWithValue("@filetype", fileType);
                cmdUpdate.Parameters.AddWithValue("@filedata", fileData);
                cmdUpdate.Parameters.AddWithValue("@docdate", DateTime.Now);
                cmdUpdate.Parameters.AddWithValue("@docuser", username);
                cmdUpdate.Parameters.AddWithValue("@regno", regno);
                cmdUpdate.Parameters.AddWithValue("@doccode", docCode);
                cmdUpdate.ExecuteNonQuery();
            }
            else
            {
                // Insert new
                string sqlInsert = @"INSERT INTO stddoc (docbioid, doccode, docfilename, docfiletype, docblob, docdate, docuser)
                                     VALUES (@regno, @doccode, @filename, @filetype, @filedata, @docdate, @docuser)";
                MySqlCommand cmdInsert = new MySqlCommand(sqlInsert, conn);
                cmdInsert.Parameters.AddWithValue("@regno", regno);
                cmdInsert.Parameters.AddWithValue("@doccode", docCode);
                cmdInsert.Parameters.AddWithValue("@filename", fileName);
                cmdInsert.Parameters.AddWithValue("@filetype", fileType);
                cmdInsert.Parameters.AddWithValue("@filedata", fileData);
                cmdInsert.Parameters.AddWithValue("@docdate", DateTime.Now);
                cmdInsert.Parameters.AddWithValue("@docuser", username);
                cmdInsert.ExecuteNonQuery();
            }
        }

        BindGrid();
        UpdateStats();
        ShowMessage("Document uploaded successfully.");
    }

    #endregion

    #region Batch Actions

    protected void btnPrintList_Click(object sender, EventArgs e)
    {
        // Print functionality - can be extended
        ShowMessage("Print functionality will be implemented.");
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        // Export to Excel
        gveDocuments.WriteXlsxToResponse(new XlsxExportOptionsEx() { ExportType = ExportType.WYSIWYG });
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        BindGrid();
        UpdateStats();
    }

    #endregion

    #region Helpers

    protected string GetStatusClass(string status)
    {
        switch (status.ToUpper())
        {
            case "COMPLETE": return "complete";
            case "PARTIAL": return "partial";
            case "MISSING": return "missing";
            default: return "missing";
        }
    }

    private void ShowMessage(string message)
    {
        litMessage.Text = message;
        popMessage.ShowOnPageLoad = true;
    }

    #endregion
}
