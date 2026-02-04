using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_UserControls_BatchOperations : System.Web.UI.UserControl
{
    protected string ConnectionString
    {
        get 
        { 
            // Try multiple connection string names for compatibility
            if (ConfigurationManager.ConnectionStrings["vacConnectionString"] != null)
                return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            if (ConfigurationManager.ConnectionStrings["aboraboraboraborasaboraborababorab"] != null)
                return ConfigurationManager.ConnectionStrings["aboraboraboraborasaboraborababorab"].ConnectionString;
            return "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX requests
        string action = Request.QueryString["action"];
        if (!string.IsNullOrEmpty(action))
        {
            BatchOperationsHelper.ProcessAjaxRequest(action, Request, Response, ConnectionString);
            return;
        }

        if (!IsPostBack)
        {
            LoadDropdowns();
        }
    }

    private void LoadDropdowns()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // Load Programmes - column is progname, not prog
                string sql = @"SELECT DISTINCT p.progcode, p.progname 
                             FROM acad_programme p 
                             INNER JOIN acad_student s ON p.progcode = s.progid 
                             WHERE p.progcode <> '-'
                             ORDER BY p.progname";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["progcode"].ToString();
                        string title = reader["progname"].ToString();
                        ddlBatchProgramme.Items.Add(new ListItem(title, code));
                        ddlValidationProgramme.Items.Add(new ListItem(title, code));
                    }
                }

                // Entry Years
                sql = @"SELECT DISTINCT entryyear FROM acad_student 
                      WHERE entryyear IS NOT NULL AND entryyear != '' 
                      ORDER BY entryyear DESC";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string year = reader["entryyear"].ToString();
                        ddlBatchEntryYear.Items.Add(new ListItem(year, year));
                        ddlValidationEntryYear.Items.Add(new ListItem(year, year));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("BatchOperations LoadDropdowns Error: " + ex.Message);
        }
    }
}
