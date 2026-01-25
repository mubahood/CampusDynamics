using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_StudentInfo_StudentEditor : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    
    //protected void cmdExport_Click(object sender, EventArgs e)
    //{
    //    GVE_Students.WriteXlsToResponse("StudentList", new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    //}
    //protected void CPB_Export_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    //{
    //    GVE_Students.WriteXlsToResponse("StudentList", new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    //}
    protected void CBP_Students_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {

    }
    protected void cmdAddNew_Click1(object sender, EventArgs e)
    {
        gvStudentInfo.AddNewRow();
    }
    //protected void cmdSpecs_Click(object sender, EventArgs e)
    //{
    //    pop_messagebox.ContentUrl = "~/COOPERP/StudentInfo/SpecialisationManager.aspx";
    //    pop_messagebox.Width = 600;
    //    pop_messagebox.Height = 450;
    //    pop_messagebox.ShowOnPageLoad = true;
    //}
    protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {
        pop_messagebox.Width = 1000;
        pop_messagebox.Height = 500;
        Session["regno"] = gvStudentInfo.GetRowValues(gvStudentInfo.FocusedRowIndex, "regno");
        pop_messagebox.ContentUrl = "~/COOPERP/StudentInfo/StudentProfile.aspx";
        pop_messagebox.ShowOnPageLoad = true;
    }
}