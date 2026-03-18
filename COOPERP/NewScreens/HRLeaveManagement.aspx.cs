using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_HRLeaveManagement : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadYearDropdown();
            LoadDepartmentDropdown();
            LoadEmployeeDropdowns();
            txtAllocYear.Text = DateTime.Now.Year.ToString();
        }
        litCurrentYear.Text = ddlLeaveYear.SelectedValue;
        BindLeaveGrid();
        BindLeaveHistoryGrid();
        LoadStats();
    }

    #region Data Loading

    private void LoadYearDropdown()
    {
        ddlLeaveYear.Items.Clear();
        int currentYear = DateTime.Now.Year;
        for (int y = currentYear + 1; y >= currentYear - 5; y--)
        {
            ddlLeaveYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        }
        ddlLeaveYear.SelectedValue = currentYear.ToString();
    }

    private void LoadDepartmentDropdown()
    {
        DataTable dt = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlLeaveDept.Items.Clear();
        ddlLeaveDept.Items.Add(new ListItem("All Departments", ""));
        foreach (DataRow r in dt.Rows)
        {
            ddlLeaveDept.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));
        }
    }

    private void LoadEmployeeDropdowns()
    {
        DataTable dt = ExecuteQuery("SELECT empID, CONCAT(emp_name, ' [', IFNULL(EMP_CODE,''), ']') AS display FROM hrm_employee ORDER BY emp_name");

        ddlAllocEmployee.Items.Clear();
        ddlAllocEmployee.Items.Add(new ListItem("-- Select Employee --", ""));
        ddlRecordEmployee.Items.Clear();
        ddlRecordEmployee.Items.Add(new ListItem("-- Select Employee --", ""));

        foreach (DataRow r in dt.Rows)
        {
            string val = r["empID"].ToString();
            string txt = r["display"].ToString();
            ddlAllocEmployee.Items.Add(new ListItem(txt, val));
            ddlRecordEmployee.Items.Add(new ListItem(txt, val));
        }
    }

    private void LoadStats()
    {
        string year = ddlLeaveYear.SelectedValue;

        DataTable dtStats = ExecuteQuery(@"
            SELECT 
                COUNT(DISTINCT al.empID) AS total_staff,
                COALESCE(SUM(lt_sum.total_taken),0) AS total_days_taken,
                (SELECT COUNT(*) FROM hrm_leave_taken lt2 
                 JOIN hrm_annual_leave al2 ON al2.ID = lt2.leaveID
                 WHERE al2.leave_year = @yr AND lt2.startDate <= CURDATE() AND lt2.endDate >= CURDATE()) AS on_leave,
                SUM(CASE WHEN al.default_days <= COALESCE(lt_sum.total_taken,0) THEN 1 ELSE 0 END) AS exhausted
            FROM hrm_annual_leave al
            LEFT JOIN (
                SELECT leaveID, SUM(no_days) AS total_taken FROM hrm_leave_taken GROUP BY leaveID
            ) lt_sum ON lt_sum.leaveID = al.ID
            WHERE al.leave_year = @yr",
            new MySqlParameter("@yr", year));

        if (dtStats.Rows.Count > 0)
        {
            DataRow r = dtStats.Rows[0];
            litTotalStaff.Text = r["total_staff"].ToString();
            litTotalDaysTaken.Text = r["total_days_taken"].ToString();
            litOnLeave.Text = r["on_leave"].ToString();
            litExhausted.Text = r["exhausted"].ToString();
        }
    }

    #endregion

    #region Leave Allocation Grid

    private void BindLeaveGrid()
    {
        string year = ddlLeaveYear.SelectedValue;
        string search = txtLeaveSearch.Text.Trim();
        string dept = ddlLeaveDept.SelectedValue;

        StringBuilder sql = new StringBuilder();
        sql.Append(@"SELECT al.ID AS leaveAllocID, al.leave_year, al.default_days,
            e.empID, e.EMP_CODE, e.emp_name,
            d.dept_name,
            COALESCE(lt_sum.total_taken, 0) AS taken_days,
            (al.default_days - COALESCE(lt_sum.total_taken, 0)) AS remaining
        FROM hrm_annual_leave al
        JOIN hrm_employee e ON e.empID = al.empID
        LEFT JOIN (
            SELECT leaveID, SUM(no_days) AS total_taken FROM hrm_leave_taken GROUP BY leaveID
        ) lt_sum ON lt_sum.leaveID = al.ID
        LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
        LEFT JOIN hrm_departments d ON d.ID = c.departmentID
        WHERE al.leave_year = @yr ");

        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@yr", year));

        if (!string.IsNullOrEmpty(search))
        {
            sql.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search) ");
            parms.Add(new MySqlParameter("@search", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(dept))
        {
            sql.Append(" AND c.departmentID = @dept ");
            parms.Add(new MySqlParameter("@dept", dept));
        }

        sql.Append(" ORDER BY e.emp_name ");

        DataTable dt = ExecuteQuery(sql.ToString(), parms.ToArray());
        gvLeave.DataSource = dt;
        gvLeave.DataBind();
    }

    private void BindLeaveHistoryGrid()
    {
        string year = ddlLeaveYear.SelectedValue;

        DataTable dt = ExecuteQuery(@"
            SELECT lt.ID AS leaveRecID, lt.startDate, lt.endDate, lt.no_days,
                al.leave_year, e.EMP_CODE, e.emp_name, d.dept_name
            FROM hrm_leave_taken lt
            JOIN hrm_annual_leave al ON al.ID = lt.leaveID
            JOIN hrm_employee e ON e.empID = al.empID
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            WHERE al.leave_year = @yr
            ORDER BY lt.startDate DESC",
            new MySqlParameter("@yr", year));

        gvLeaveHistory.DataSource = dt;
        gvLeaveHistory.DataBind();
    }

    #endregion

    #region Grid Events

    protected void gvLeave_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int allocID = Convert.ToInt32(e.Keys["leaveAllocID"]);
        int newDays = Convert.ToInt32(e.NewValues["default_days"]);

        ExecuteNonQuery("UPDATE hrm_annual_leave SET default_days = @days WHERE ID = @id",
            new MySqlParameter("@days", newDays),
            new MySqlParameter("@id", allocID));

        e.Cancel = true;
        gvLeave.CancelEdit();
        BindLeaveGrid();
    }

    protected void gvLeave_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int allocID = Convert.ToInt32(e.Keys["leaveAllocID"]);
        // Delete leave taken records first
        ExecuteNonQuery("DELETE FROM hrm_leave_taken WHERE leaveID = @id", new MySqlParameter("@id", allocID));
        ExecuteNonQuery("DELETE FROM hrm_annual_leave WHERE ID = @id", new MySqlParameter("@id", allocID));

        e.Cancel = true;
        gvLeave.CancelEdit();
        BindLeaveGrid();
        BindLeaveHistoryGrid();
    }

    protected void gvLeaveHistory_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int recID = Convert.ToInt32(e.Keys["leaveRecID"]);
        ExecuteNonQuery("DELETE FROM hrm_leave_taken WHERE ID = @id", new MySqlParameter("@id", recID));

        e.Cancel = true;
        gvLeaveHistory.CancelEdit();
        BindLeaveGrid();
        BindLeaveHistoryGrid();
    }

    #endregion

    #region Filter Events

    protected void ddlLeaveYear_Changed(object sender, EventArgs e)
    {
        BindLeaveGrid();
        BindLeaveHistoryGrid();
        LoadStats();
    }

    protected void btnLeaveSearch_Click(object sender, EventArgs e)
    {
        BindLeaveGrid();
    }

    protected void btnLeaveReset_Click(object sender, EventArgs e)
    {
        txtLeaveSearch.Text = "";
        ddlLeaveDept.SelectedIndex = 0;
        ddlLeaveYear.SelectedValue = DateTime.Now.Year.ToString();
        BindLeaveGrid();
        BindLeaveHistoryGrid();
        LoadStats();
    }

    #endregion

    #region Allocate Leave

    protected void btnAllocateLeave_Click(object sender, EventArgs e)
    {
        string empID = ddlAllocEmployee.SelectedValue;
        string yearStr = txtAllocYear.Text.Trim();
        string daysStr = txtAllocDays.Text.Trim();

        if (string.IsNullOrEmpty(empID) || string.IsNullOrEmpty(yearStr) || string.IsNullOrEmpty(daysStr))
        {
            ShowModalError("allocateModal", "allocResult", "All fields are required.");
            return;
        }

        int year, days;
        if (!int.TryParse(yearStr, out year) || !int.TryParse(daysStr, out days))
        {
            ShowModalError("allocateModal", "allocResult", "Invalid year or days value.");
            return;
        }

        // Check if allocation already exists
        DataTable existing = ExecuteQuery(
            "SELECT ID FROM hrm_annual_leave WHERE empID = @eid AND leave_year = @yr",
            new MySqlParameter("@eid", empID),
            new MySqlParameter("@yr", year.ToString()));

        if (existing.Rows.Count > 0)
        {
            ShowModalError("allocateModal", "allocResult", "Allocation already exists for this employee and year. Edit it from the grid.");
            return;
        }

        ExecuteNonQuery("INSERT INTO hrm_annual_leave (empID, leave_year, default_days) VALUES (@eid, @yr, @days)",
            new MySqlParameter("@eid", empID),
            new MySqlParameter("@yr", year.ToString()),
            new MySqlParameter("@days", days));

        BindLeaveGrid();
        LoadStats();
    }

    #endregion

    #region Record Leave

    protected void ddlRecordEmployee_Changed(object sender, EventArgs e)
    {
        string empID = ddlRecordEmployee.SelectedValue;
        if (string.IsNullOrEmpty(empID)) return;

        string year = DateTime.Now.Year.ToString();
        DataTable dt = ExecuteQuery(@"
            SELECT al.ID, al.default_days, COALESCE(SUM(lt.no_days),0) AS taken
            FROM hrm_annual_leave al
            LEFT JOIN hrm_leave_taken lt ON lt.leaveID = al.ID
            WHERE al.empID = @eid AND al.leave_year = @yr
            GROUP BY al.ID, al.default_days",
            new MySqlParameter("@eid", empID),
            new MySqlParameter("@yr", year));

        if (dt.Rows.Count > 0)
        {
            int allocated = Convert.ToInt32(dt.Rows[0]["default_days"]);
            int taken = Convert.ToInt32(dt.Rows[0]["taken"]);
            int remaining = allocated - taken;
            hdnLeaveAllocID.Value = dt.Rows[0]["ID"].ToString();
            litEmpLeaveInfo.Text = string.Format("Allocated: <strong>{0}</strong> days | Taken: <strong>{1}</strong> | Remaining: <strong>{2}</strong>", allocated, taken, remaining);
            ScriptManager.RegisterStartupScript(this, GetType(), "showInfo",
                "document.getElementById('empLeaveInfo').style.display='block';document.getElementById('recordLeaveModal').style.display='flex';", true);
        }
        else
        {
            hdnLeaveAllocID.Value = "";
            litEmpLeaveInfo.Text = "<span style='color:#dc3545;'>No leave allocation found for " + year + ". Please allocate leave first.</span>";
            ScriptManager.RegisterStartupScript(this, GetType(), "showInfo",
                "document.getElementById('empLeaveInfo').style.display='block';document.getElementById('recordLeaveModal').style.display='flex';", true);
        }
    }

    protected void btnRecordLeave_Click(object sender, EventArgs e)
    {
        string allocID = hdnLeaveAllocID.Value;
        if (string.IsNullOrEmpty(allocID))
        {
            ShowModalError("recordLeaveModal", "recordResult", "No leave allocation found. Please allocate leave first.");
            return;
        }

        DateTime startDate, endDate;
        int noDays;

        if (!DateTime.TryParse(txtLeaveStart.Text, out startDate) || !DateTime.TryParse(txtLeaveEnd.Text, out endDate))
        {
            ShowModalError("recordLeaveModal", "recordResult", "Please provide valid start and end dates.");
            return;
        }

        if (!int.TryParse(txtLeaveDays.Text, out noDays) || noDays <= 0)
        {
            ShowModalError("recordLeaveModal", "recordResult", "Please provide a valid number of days.");
            return;
        }

        if (endDate < startDate)
        {
            ShowModalError("recordLeaveModal", "recordResult", "End date cannot be before start date.");
            return;
        }

        // Check remaining days
        DataTable dtCheck = ExecuteQuery(@"
            SELECT al.default_days, COALESCE(SUM(lt.no_days),0) AS taken
            FROM hrm_annual_leave al
            LEFT JOIN hrm_leave_taken lt ON lt.leaveID = al.ID
            WHERE al.ID = @id
            GROUP BY al.ID, al.default_days",
            new MySqlParameter("@id", allocID));

        if (dtCheck.Rows.Count > 0)
        {
            int allocated = Convert.ToInt32(dtCheck.Rows[0]["default_days"]);
            int taken = Convert.ToInt32(dtCheck.Rows[0]["taken"]);
            if (taken + noDays > allocated)
            {
                ShowModalError("recordLeaveModal", "recordResult",
                    string.Format("Cannot record {0} days. Only {1} days remaining.", noDays, allocated - taken));
                return;
            }
        }

        ExecuteNonQuery(@"INSERT INTO hrm_leave_taken (leaveID, startDate, endDate, no_days) VALUES (@lid, @start, @end, @days)",
            new MySqlParameter("@lid", allocID),
            new MySqlParameter("@start", startDate),
            new MySqlParameter("@end", endDate),
            new MySqlParameter("@days", noDays));

        txtLeaveStart.Text = "";
        txtLeaveEnd.Text = "";
        txtLeaveDays.Text = "";

        BindLeaveGrid();
        BindLeaveHistoryGrid();
        LoadStats();
    }

    #endregion

    #region Template Helpers

    protected string GetRemainingHtml(object allocatedObj, object takenObj)
    {
        int allocated = 0, taken = 0;
        if (allocatedObj != null && allocatedObj != DBNull.Value) allocated = Convert.ToInt32(allocatedObj);
        if (takenObj != null && takenObj != DBNull.Value) taken = Convert.ToInt32(takenObj);

        int remaining = allocated - taken;
        double pct = allocated > 0 ? ((double)remaining / allocated) * 100 : 0;
        string barColor = remaining <= 0 ? "#dc3545" : remaining <= 5 ? "#ffc107" : "#28a745";
        string textColor = remaining <= 0 ? "#dc3545" : remaining <= 5 ? "#856404" : "#28a745";

        return string.Format(
            "<div><strong style='color:{0};'>{1}</strong> <span style='font-size:9px;color:#888;'>of {2}</span>" +
            "<div class='lv-days-bar'><div class='lv-days-bar__fill' style='width:{3}%;background:{4};'></div></div></div>",
            textColor, remaining, allocated, Math.Max(pct, 0), barColor);
    }

    protected string GetLeaveStatusBadge(object allocatedObj, object takenObj)
    {
        int allocated = 0, taken = 0;
        if (allocatedObj != null && allocatedObj != DBNull.Value) allocated = Convert.ToInt32(allocatedObj);
        if (takenObj != null && takenObj != DBNull.Value) taken = Convert.ToInt32(takenObj);

        int remaining = allocated - taken;
        if (remaining <= 0) return "<span class='hr-badge hr-badge--danger'>EXHAUSTED</span>";
        if (remaining <= 5) return "<span class='hr-badge hr-badge--warning'>LOW</span>";
        return "<span class='hr-badge hr-badge--success'>AVAILABLE</span>";
    }

    #endregion

    #region Helpers

    private void ShowModalError(string modalId, string resultId, string message)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "modalErr",
            "document.getElementById('" + resultId + "').innerHTML='<span style=\"color:red;\">" +
            HttpUtility.JavaScriptStringEncode(message) + "</span>';document.getElementById('" + modalId + "').style.display='flex';", true);
    }

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
