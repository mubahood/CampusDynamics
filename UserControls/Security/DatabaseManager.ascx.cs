using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Data;
using DevExpress.Web;
using System.Configuration;
using System.Text;

public partial class UserControls_Security_DatabaseManager : System.Web.UI.UserControl
{
    private List<string> commandHistory = new List<string>();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["DBCommandHistory"] != null)
        {
            commandHistory = (List<string>)Session["DBCommandHistory"];
        }
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtCommand.Text))
        {
            lbl_msg.ForeColor = System.Drawing.Color.Red;
            lbl_msg.Text = "Please enter a SQL command";
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }

        MySqlConnection conn = null;
        MySqlCommand comm = null;
        DateTime startTime = DateTime.Now;

        try
        {
            conn = new MySqlConnection();
            conn.ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            conn.Open();
            comm = new MySqlCommand();
            comm.Connection = conn;
            comm.CommandTimeout = 300; // 5 minutes timeout

            string commandText = txtCommand.Text.Trim();
            
            // Add to history
            if (!commandHistory.Contains(commandText))
            {
                commandHistory.Add(commandText);
                if (commandHistory.Count > 50) commandHistory.RemoveAt(0); // Keep last 50
                Session["DBCommandHistory"] = commandHistory;
            }

            // Remove trailing semicolon if present
            if (commandText.EndsWith(";"))
            {
                commandText = commandText.Substring(0, commandText.Length - 1).Trim();
            }

            // Determine if command returns data
            string upperCommand = commandText.ToUpper().Trim();
            bool returnsData = upperCommand.StartsWith("SELECT") ||
                              upperCommand.StartsWith("SHOW") ||
                              upperCommand.StartsWith("DESCRIBE") ||
                              upperCommand.StartsWith("DESC") ||
                              upperCommand.StartsWith("EXPLAIN") ||
                              upperCommand.StartsWith("CALL");

            if (returnsData)
            {
                // Commands that return data
                // For SELECT queries, automatically add LIMIT if not present to prevent large result sets
                if (upperCommand.StartsWith("SELECT"))
                {
                    // Check if LIMIT already exists in the query
                    if (!upperCommand.Contains("LIMIT"))
                    {
                        // Add LIMIT 5000 to prevent memory issues
                        if (commandText.TrimEnd().EndsWith(";"))
                        {
                            commandText = commandText.TrimEnd().Substring(0, commandText.TrimEnd().Length - 1);
                        }
                        comm.CommandText = string.Format("{0} LIMIT 5000", commandText);
                    }
                    else
                    {
                        comm.CommandText = commandText;
                    }
                }
                else
                {
                    comm.CommandText = commandText;
                }

                MySqlDataReader dr = null;
                try
                {
                    dr = comm.ExecuteReader();
                    DataTable dataTable = new DataTable();
                    dataTable.Load(dr);
                    dr.Close();

                    if (dataTable.Rows.Count > 0)
                    {
                        if (dataTable.Columns.Count > 0)
                        {
                            gvDataset.KeyFieldName = dataTable.Columns[0].ColumnName;
                        }
                        gvDataset.DataSource = dataTable;
                        gvDataset.DataBind();
                        
                        TimeSpan duration = DateTime.Now - startTime;
                        lbl_msg.ForeColor = System.Drawing.Color.Blue;
                        string limitNote = upperCommand.StartsWith("SELECT") && !upperCommand.Contains("LIMIT") ? " (Limited to 5000 rows)" : "";
                        lbl_msg.Text = string.Format("Query executed successfully. Returned {0} row(s) in {1}ms{2}", 
                            dataTable.Rows.Count, duration.TotalMilliseconds.ToString("F0"), limitNote);
                    }
                    else
                    {
                        gvDataset.DataSource = null;
                        gvDataset.DataBind();
                        TimeSpan duration = DateTime.Now - startTime;
                        lbl_msg.ForeColor = System.Drawing.Color.Blue;
                        lbl_msg.Text = string.Format("Query executed successfully. No rows returned. ({0}ms)", 
                            duration.TotalMilliseconds.ToString("F0"));
                    }
                }
                finally
                {
                    if (dr != null && !dr.IsClosed) dr.Close();
                }
            }
            else
            {
                // Commands that don't return data (INSERT, UPDATE, DELETE, DROP, CREATE, ALTER, TRUNCATE, etc.)
                comm.CommandText = commandText;
                int rowsAffected = comm.ExecuteNonQuery();
                
                TimeSpan duration = DateTime.Now - startTime;
                lbl_msg.ForeColor = System.Drawing.Color.Blue;
                
                if (rowsAffected >= 0)
                {
                    lbl_msg.Text = string.Format("Command executed successfully. {0} row(s) affected. ({1}ms)", 
                        rowsAffected, duration.TotalMilliseconds.ToString("F0"));
                }
                else
                {
                    lbl_msg.Text = string.Format("Command executed successfully. ({0}ms)", 
                        duration.TotalMilliseconds.ToString("F0"));
                }

                // Clear grid for non-SELECT commands
                gvDataset.DataSource = null;
                gvDataset.DataBind();
            }
        }
        catch (MySqlException sqlEx)
        {
            lbl_msg.ForeColor = System.Drawing.Color.Red;
            lbl_msg.Text = string.Format("MySQL Error [{0}]: {1}", sqlEx.Number, sqlEx.Message);
            gvDataset.DataSource = null;
            gvDataset.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg.ForeColor = System.Drawing.Color.Red;
            lbl_msg.Text = string.Format("Error: {0}", ex.Message);
            gvDataset.DataSource = null;
            gvDataset.DataBind();
        }
        finally
        {
            if (comm != null) comm.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }

        pop_messagebox.ShowOnPageLoad = true;
    }

    protected void cmdClear_Click(object sender, EventArgs e)
    {
        txtCommand.Text = "";
        gvDataset.DataSource = null;
        gvDataset.DataBind();
    }

    protected void cmdClear0_Click(object sender, EventArgs e)
    {
        if (commandHistory.Count > 0)
        {
            StringBuilder historyText = new StringBuilder();
            historyText.AppendLine("Command History (Last 50 commands):");
            historyText.AppendLine("-----------------------------------");
            for (int i = commandHistory.Count - 1; i >= 0; i--)
            {
                historyText.AppendLine(string.Format("{0}. {1}", commandHistory.Count - i, commandHistory[i]));
            }
            txtCommand.Text = historyText.ToString();
        }
        else
        {
            lbl_msg.ForeColor = System.Drawing.Color.Blue;
            lbl_msg.Text = "No command history available";
            pop_messagebox.ShowOnPageLoad = true;
        }
    }
}