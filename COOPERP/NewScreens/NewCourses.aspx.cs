using System;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_NewCourses : Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadStats();
        }
    }

    private void LoadStats()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            try
            {
                conn.Open();
                
                // Total courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE courseID != ''", conn))
                {
                    lblTotalCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Active courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE stat = 'Active' AND courseID != ''", conn))
                {
                    lblActiveCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Inactive courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE (stat = 'Inactive' OR stat IS NULL OR stat = '') AND courseID != ''", conn))
                {
                    lblInactiveCourses.Text = cmd.ExecuteScalar().ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading stats: " + ex.Message);
            }
        }
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvMain.AddNewRow();
    }

    protected void gvMain_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        // Refresh stats after update
    }

    protected void gvMain_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        // Set default values if not provided
        if (e.NewValues["stat"] == null || string.IsNullOrEmpty(e.NewValues["stat"].ToString()))
        {
            e.NewValues["stat"] = "Active";
        }
        if (e.NewValues["CoreStatus"] == null || string.IsNullOrEmpty(e.NewValues["CoreStatus"].ToString()))
        {
            e.NewValues["CoreStatus"] = "Core";
        }
    }
}
