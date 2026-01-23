using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_NewFacultyProgrammes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Ensure is_fully_set column exists
            EnsureIsFullySetColumn();
        }
    }

    private void EnsureIsFullySetColumn()
    {
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                // Check if column exists
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'campus_dynamics' AND TABLE_NAME = 'acad_programme' AND COLUMN_NAME = 'is_fully_set'";
                using (MySqlCommand cmd = new MySqlCommand(checkSql, conn))
                {
                    int exists = Convert.ToInt32(cmd.ExecuteScalar());
                    if (exists == 0)
                    {
                        // Add column if it doesn't exist
                        string alterSql = "ALTER TABLE acad_programme ADD COLUMN is_fully_set VARCHAR(10) DEFAULT 'No'";
                        using (MySqlCommand alterCmd = new MySqlCommand(alterSql, conn))
                        {
                            alterCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
        }
        catch (Exception)
        {
            // Column may already exist or other non-critical error
        }
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvMain.AddNewRow();
    }

    protected void gvMain_RowCommand(object sender, EventArgs e)
    {
        // Handle row commands if needed
    }

    protected void gvMain_CellEditorInitialize(object sender, ASPxGridViewEditorEventArgs e)
    {
        // Only allow inline editing for the is_fully_set column
        if (e.Column.FieldName != "is_fully_set")
        {
            e.Editor.ReadOnly = true;
        }
    }

    protected void gvMain_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        // Update only the is_fully_set field via direct SQL for cleaner inline update
        try
        {
            string progcode = e.Keys["progcode"].ToString();
            string isFullySet = e.NewValues["is_fully_set"] != null ? e.NewValues["is_fully_set"].ToString() : "No";

            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string sql = "UPDATE acad_programme SET is_fully_set = @is_fully_set WHERE progcode = @progcode";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@is_fully_set", isFullySet);
                    cmd.Parameters.AddWithValue("@progcode", progcode);
                    cmd.ExecuteNonQuery();
                }
            }

            e.Cancel = true;
            gvMain.CancelEdit();
            gvMain.DataBind();
        }
        catch (Exception ex)
        {
            e.Cancel = true;
            throw new Exception("Error updating status: " + ex.Message);
        }
    }

    protected void cmdStructure_Click(object sender, EventArgs e)
    {
        // Get the focused row values
        object progcodeObj = gvMain.GetRowValues(gvMain.FocusedRowIndex, "progcode");
        object prognameObj = gvMain.GetRowValues(gvMain.FocusedRowIndex, "progname");
        
        string progcode = progcodeObj != null ? progcodeObj.ToString() : string.Empty;
        string progname = prognameObj != null ? prognameObj.ToString() : string.Empty;
        
        if (!string.IsNullOrEmpty(progcode))
        {
            // Store in session for the structure page
            Session["prog"] = progcode;
            Session["progname"] = progname;
            
            // Set popup properties and show
            popStructure.HeaderText = "PROGRAMME STRUCTURE: " + progname + " [" + progcode + "]";
            popStructure.ContentUrl = "~/COOPERP/Faculty/ProgrammeStructure.aspx";
            popStructure.ShowOnPageLoad = true;
        }
    }
}
