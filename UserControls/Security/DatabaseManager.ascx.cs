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

public partial class UserControls_Security_DatabaseManager : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        MySqlCommand comm = new MySqlCommand();
        MySqlConnection conn = new MySqlConnection();
        conn.ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        conn.Open();
        comm.Connection = conn;
        string commandText = txtCommand.Text;
        commandText=commandText.Replace("select","SELECT");
        commandText = commandText.Replace("call", "CALL");
        
        
        DataTable TAB = new DataTable();
        try
        {

            if (commandText.StartsWith("SELECT") || commandText.StartsWith("CALL"))
            {
                commandText=commandText.Replace(";", "");
                if (commandText.StartsWith("SELECT")) 
                {
                    comm.CommandText = string.Format("{0} LIMIT 5000", txtCommand.Text);
                }
               
                    MySqlDataReader dr = comm.ExecuteReader();
                    DataSet ds = new DataSet();
                    DataTable dataTable = new DataTable();
                    ds.Tables.Clear();
                    ds.Tables.Add(dataTable);
                    ds.EnforceConstraints = false;
                    dataTable.Load(dr);
                    dr.Close();
                    gvDataset.KeyFieldName = dataTable.Columns[0].ColumnName;
                    gvDataset.DataSource = dataTable;
                    gvDataset.DataBind();
                    lbl_msg.ForeColor = System.Drawing.Color.Blue;
                
                
            }
            else
            {
                comm.CommandText = commandText;
                comm.ExecuteNonQuery();
                lbl_msg.ForeColor = System.Drawing.Color.Blue;
            }
            
            lbl_msg.Text = "Command Executed Successfully";
        }
        catch (Exception ex)
        {
            lbl_msg.ForeColor = System.Drawing.Color.Red;
            lbl_msg.Text = "An Error Occured. "+ex.Message;

        }
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        txtCommand.Text = "";
        gvDataset.DataBind();
    }
    protected void cmdClear0_Click(object sender, EventArgs e)
    {

    }
}