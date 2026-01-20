using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_financials_FeesPaySchedule : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string regno = Request["regno"];
        DataTable stud_data;
        StudentDataTableAdapters.acad_studentTableAdapter STUDDATA= new StudentDataTableAdapters.acad_studentTableAdapter();
        stud_data = STUDDATA.GetStudentSearch(Request["regno"]);
        Session["prog"] = stud_data.Rows[0]["progid"].ToString();
        Session["eyr"] = stud_data.Rows[0]["entryyear"].ToString();
        Session["bid"] = stud_data.Rows[0]["billingID"].ToString();
        Session["sess"] = stud_data.Rows[0]["studsesion"].ToString();
    }
    
    protected void gvFeesSchedule_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdPrintSchedule_Click(object sender, EventArgs e)
    {

    }
}