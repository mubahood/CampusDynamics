using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_HRSettings : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindAllGrids();
        }
    }

    private void BindAllGrids()
    {
        BindDepartments();
        BindJobs();
        BindStations();
        BindPayScales();
        BindBanks();
        BindAllowDed();
    }

    #region Departments

    private void BindDepartments()
    {
        DataTable dt = ExecuteQuery(@"SELECT d.ID, d.dept_name, d.dept_headID, 
            IFNULL(e.emp_name,'') AS head_name
            FROM hrm_departments d LEFT JOIN hrm_employee e ON e.empID = d.dept_headID
            ORDER BY d.dept_name");
        gvDepartments.DataSource = dt;
        gvDepartments.DataBind();
    }

    protected void gvDepartments_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        string name = e.NewValues["dept_name"] != null ? e.NewValues["dept_name"].ToString() : "";
        object headID = e.NewValues["dept_headID"];
        ExecuteNonQuery("INSERT INTO hrm_departments (dept_name, dept_headID) VALUES (@name, @head)",
            new MySqlParameter("@name", name),
            new MySqlParameter("@head", headID != null && headID.ToString() != "" ? (object)Convert.ToInt32(headID) : DBNull.Value));
        e.Cancel = true;
        gvDepartments.CancelEdit();
        BindDepartments();
    }

    protected void gvDepartments_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        string name = e.NewValues["dept_name"] != null ? e.NewValues["dept_name"].ToString() : "";
        object headID = e.NewValues["dept_headID"];
        ExecuteNonQuery("UPDATE hrm_departments SET dept_name=@name, dept_headID=@head WHERE ID=@id",
            new MySqlParameter("@name", name),
            new MySqlParameter("@head", headID != null && headID.ToString() != "" ? (object)Convert.ToInt32(headID) : DBNull.Value),
            new MySqlParameter("@id", id));
        e.Cancel = true;
        gvDepartments.CancelEdit();
        BindDepartments();
    }

    protected void gvDepartments_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("DELETE FROM hrm_departments WHERE ID=@id", new MySqlParameter("@id", id));
        e.Cancel = true;
        gvDepartments.CancelEdit();
        BindDepartments();
    }

    #endregion

    #region Jobs

    private void BindJobs()
    {
        DataTable dt = ExecuteQuery("SELECT ID, jobname, min_qualifications FROM hrm_jobs ORDER BY jobname");
        gvJobs.DataSource = dt;
        gvJobs.DataBind();
    }

    protected void gvJobs_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        ExecuteNonQuery("INSERT INTO hrm_jobs (jobname, min_qualifications) VALUES (@name, @qual)",
            new MySqlParameter("@name", e.NewValues["jobname"] != null ? e.NewValues["jobname"].ToString() : ""),
            new MySqlParameter("@qual", e.NewValues["min_qualifications"] != null ? e.NewValues["min_qualifications"].ToString() : ""));
        e.Cancel = true; gvJobs.CancelEdit(); BindJobs();
    }

    protected void gvJobs_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("UPDATE hrm_jobs SET jobname=@name, min_qualifications=@qual WHERE ID=@id",
            new MySqlParameter("@name", e.NewValues["jobname"] != null ? e.NewValues["jobname"].ToString() : ""),
            new MySqlParameter("@qual", e.NewValues["min_qualifications"] != null ? e.NewValues["min_qualifications"].ToString() : ""),
            new MySqlParameter("@id", id));
        e.Cancel = true; gvJobs.CancelEdit(); BindJobs();
    }

    protected void gvJobs_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("DELETE FROM hrm_jobs WHERE ID=@id", new MySqlParameter("@id", id));
        e.Cancel = true; gvJobs.CancelEdit(); BindJobs();
    }

    #endregion

    #region Stations

    private void BindStations()
    {
        DataTable dt = ExecuteQuery("SELECT ID, station_name FROM hrm_stations ORDER BY station_name");
        gvStations.DataSource = dt;
        gvStations.DataBind();
    }

    protected void gvStations_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        ExecuteNonQuery("INSERT INTO hrm_stations (station_name) VALUES (@name)",
            new MySqlParameter("@name", e.NewValues["station_name"] != null ? e.NewValues["station_name"].ToString() : ""));
        e.Cancel = true; gvStations.CancelEdit(); BindStations();
    }

    protected void gvStations_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("UPDATE hrm_stations SET station_name=@name WHERE ID=@id",
            new MySqlParameter("@name", e.NewValues["station_name"] != null ? e.NewValues["station_name"].ToString() : ""),
            new MySqlParameter("@id", id));
        e.Cancel = true; gvStations.CancelEdit(); BindStations();
    }

    protected void gvStations_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("DELETE FROM hrm_stations WHERE ID=@id", new MySqlParameter("@id", id));
        e.Cancel = true; gvStations.CancelEdit(); BindStations();
    }

    #endregion

    #region Pay Scales

    private void BindPayScales()
    {
        DataTable dt = ExecuteQuery("SELECT ID, scale_name, basicpay FROM hrm_payscales ORDER BY scale_name");
        gvPayScales.DataSource = dt;
        gvPayScales.DataBind();
    }

    protected void gvPayScales_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        object amt = e.NewValues["basicpay"];
        ExecuteNonQuery("INSERT INTO hrm_payscales (scale_name, basicpay) VALUES (@name, @pay)",
            new MySqlParameter("@name", e.NewValues["scale_name"] != null ? e.NewValues["scale_name"].ToString() : ""),
            new MySqlParameter("@pay", amt != null && amt.ToString() != "" ? Convert.ToDecimal(amt) : 0));
        e.Cancel = true; gvPayScales.CancelEdit(); BindPayScales();
    }

    protected void gvPayScales_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        object amt = e.NewValues["basicpay"];
        ExecuteNonQuery("UPDATE hrm_payscales SET scale_name=@name, basicpay=@pay WHERE ID=@id",
            new MySqlParameter("@name", e.NewValues["scale_name"] != null ? e.NewValues["scale_name"].ToString() : ""),
            new MySqlParameter("@pay", amt != null && amt.ToString() != "" ? Convert.ToDecimal(amt) : 0),
            new MySqlParameter("@id", id));
        e.Cancel = true; gvPayScales.CancelEdit(); BindPayScales();
    }

    protected void gvPayScales_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("DELETE FROM hrm_payscales WHERE ID=@id", new MySqlParameter("@id", id));
        e.Cancel = true; gvPayScales.CancelEdit(); BindPayScales();
    }

    #endregion

    #region Banks

    private void BindBanks()
    {
        DataTable dt = ExecuteQuery("SELECT bank_id, bank_name FROM banks ORDER BY bank_name");
        gvBanks.DataSource = dt;
        gvBanks.DataBind();
    }

    protected void gvBanks_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        ExecuteNonQuery("INSERT INTO banks (bank_name) VALUES (@name)",
            new MySqlParameter("@name", e.NewValues["bank_name"] != null ? e.NewValues["bank_name"].ToString() : ""));
        e.Cancel = true; gvBanks.CancelEdit(); BindBanks();
    }

    protected void gvBanks_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["bank_id"]);
        ExecuteNonQuery("UPDATE banks SET bank_name=@name WHERE bank_id=@id",
            new MySqlParameter("@name", e.NewValues["bank_name"] != null ? e.NewValues["bank_name"].ToString() : ""),
            new MySqlParameter("@id", id));
        e.Cancel = true; gvBanks.CancelEdit(); BindBanks();
    }

    protected void gvBanks_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["bank_id"]);
        ExecuteNonQuery("DELETE FROM banks WHERE bank_id=@id", new MySqlParameter("@id", id));
        e.Cancel = true; gvBanks.CancelEdit(); BindBanks();
    }

    #endregion

    #region Allowances & Deductions

    private void BindAllowDed()
    {
        DataTable dt = ExecuteQuery("SELECT ID, dedall_name, dedall_type, dedall_amount, computation_by, ded_allowance FROM hrm_allowance_deductions ORDER BY ded_allowance, dedall_name");
        gvAllowDed.DataSource = dt;
        gvAllowDed.DataBind();
    }

    protected void gvAllowDed_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        object amt = e.NewValues["dedall_amount"];
        ExecuteNonQuery(@"INSERT INTO hrm_allowance_deductions (dedall_name, dedall_type, dedall_amount, computation_by, ded_allowance) 
            VALUES (@name, @dtype, @amt, @comp, @da)",
            new MySqlParameter("@name", e.NewValues["dedall_name"] != null ? e.NewValues["dedall_name"].ToString() : ""),
            new MySqlParameter("@dtype", e.NewValues["dedall_type"] != null ? e.NewValues["dedall_type"].ToString() : ""),
            new MySqlParameter("@amt", amt != null && amt.ToString() != "" ? Convert.ToDecimal(amt) : 0),
            new MySqlParameter("@comp", e.NewValues["computation_by"] != null ? e.NewValues["computation_by"].ToString() : "FIXED"),
            new MySqlParameter("@da", e.NewValues["ded_allowance"] != null ? e.NewValues["ded_allowance"].ToString() : "ALLOWANCE"));
        e.Cancel = true; gvAllowDed.CancelEdit(); BindAllowDed();
    }

    protected void gvAllowDed_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        object amt = e.NewValues["dedall_amount"];
        ExecuteNonQuery(@"UPDATE hrm_allowance_deductions SET dedall_name=@name, dedall_type=@dtype, dedall_amount=@amt, 
            computation_by=@comp, ded_allowance=@da WHERE ID=@id",
            new MySqlParameter("@name", e.NewValues["dedall_name"] != null ? e.NewValues["dedall_name"].ToString() : ""),
            new MySqlParameter("@dtype", e.NewValues["dedall_type"] != null ? e.NewValues["dedall_type"].ToString() : ""),
            new MySqlParameter("@amt", amt != null && amt.ToString() != "" ? Convert.ToDecimal(amt) : 0),
            new MySqlParameter("@comp", e.NewValues["computation_by"] != null ? e.NewValues["computation_by"].ToString() : "FIXED"),
            new MySqlParameter("@da", e.NewValues["ded_allowance"] != null ? e.NewValues["ded_allowance"].ToString() : "ALLOWANCE"),
            new MySqlParameter("@id", id));
        e.Cancel = true; gvAllowDed.CancelEdit(); BindAllowDed();
    }

    protected void gvAllowDed_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        ExecuteNonQuery("DELETE FROM hrm_allowance_deductions WHERE ID=@id", new MySqlParameter("@id", id));
        e.Cancel = true; gvAllowDed.CancelEdit(); BindAllowDed();
    }

    #endregion

    #region Data Access

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    #endregion
}
