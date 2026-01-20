using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_Course_Registrations : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcad.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcad.DataBind();
            txtAcad.Text = SettingsFile.ReturnDefaultAcademicYr();
        }
    }

    protected void gvCourseRegistration_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}