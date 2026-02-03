using System;
using System.Web;

public partial class COOPERP_NewScreens_AdmittedStudents : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Redirect to NewStudentInfo.aspx with status=ADMITTED parameter
        Response.Redirect("~/COOPERP/NewScreens/NewStudentInfo.aspx?status=ADMITTED", true);
    }
}
