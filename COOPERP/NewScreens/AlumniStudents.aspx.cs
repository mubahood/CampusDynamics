using System;
using System.Web;

public partial class COOPERP_NewScreens_AlumniStudents : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Redirect to NewStudentInfo.aspx with status=ALUMNI parameter
        Response.Redirect("~/COOPERP/NewScreens/NewStudentInfo.aspx?status=ALUMNI", true);
    }
}
