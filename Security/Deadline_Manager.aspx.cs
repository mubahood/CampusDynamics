using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Results_Deadline_Manager : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadyear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadyear.DataBind();
            txtAcadyear.Text = SettingsFile.ReturnDefaultAcademicYr();
            txtAcadyear.Value = SettingsFile.ReturnDefaultAcademicYr();
        }
    }
    protected void btn_addActivity_Click(object sender, EventArgs e)
    {
        gv_Activity.AddNewRow();
    }
    protected void btn_add_Click(object sender, EventArgs e)
    {
        gv_deadlines.AddNewRow();
    }
    protected void gv_deadlines_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Contains("Exception has been thrown by the target of an invocation."))
            e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void gv_deadlines_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 30;
    }
    protected void gv_deadlines_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["CampusID"] = uint.Parse(cbx_campus.Value.ToString());
        e.NewValues["AcademicYear"] = txtAcadyear.Text;
        e.NewValues["Semester"] = txtSemester.Text;
        
    }

    protected void gv_deadlines_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        e.NewValues["StudySystem"] = txtStudysystem.Text;
    }
}