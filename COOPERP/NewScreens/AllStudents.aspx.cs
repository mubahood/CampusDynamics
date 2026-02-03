using System;
using System.Web;

public partial class COOPERP_NewScreens_AllStudents : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Redirect to NewStudentInfo.aspx with status=ALL parameter (shows all students regardless of status)
        Response.Redirect("~/COOPERP/NewScreens/NewStudentInfo.aspx?status=ALL", true);
    }
}
