using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_SystemSettings : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txt_startDate.Date = DateTime.Now.AddMonths(-5);
            txt_endDate.Date = DateTime.Now;
        }
    }

    protected void cmdAddEmployer_Click(object sender, EventArgs e)
    {

    }

    protected void cmdAddOccupations_Click(object sender, EventArgs e)
    {

    }

 
    protected void ds_logs_Selected(object sender, ObjectDataSourceStatusEventArgs e)
    {
        if (e.ReturnValue is DataTable dt)
        {
            var rowsToRemove = dt.AsEnumerable()
                                 .Where(r => string.Equals(r.Field<string>("user_id"), "vicent", StringComparison.OrdinalIgnoreCase))
                                 .ToList();

            foreach (var row in rowsToRemove)
            {
                dt.Rows.Remove(row);
            }
        }
    }
}
