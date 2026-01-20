using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Graduate_GraduateStudent : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void ASPxButton1_Click(object sender, EventArgs e)
    {
        gradStudentListGv.AddNewRow();
    }


    protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {
        pop_messagebox.Width = 1000;
        pop_messagebox.Height = 500;
        Session["regno"] = gradStudentListGv.GetRowValues(gradStudentListGv.FocusedRowIndex, "regno");
        pop_messagebox.ContentUrl = "~/COOPERP/StudentInfo/StudentProfile.aspx";
        pop_messagebox.ShowOnPageLoad = true;
    }
}