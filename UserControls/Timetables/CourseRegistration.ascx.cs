using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TimetableDataTableAdapters;

public partial class UserControls_Timetables_CourseRegistration : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcad.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcad.DataBind();
            txtAcad.Text = SettingsFile.ReturnDefaultAcademicYr();
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
            pop_msgBox.HeaderText = SettingsFile.AppName;
        }

    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        acad_GetCourseRegistrationListsTableAdapter REG = new acad_GetCourseRegistrationListsTableAdapter();
        lbl_msg.Text = REG.acad_CourseRegister(txtRegNo.Text, txtCourse.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text),
                    "RETAKE", txtProgramme.Value.ToString(), HttpContext.Current.User.Identity.Name, txtRegStatus.Text).ToString();
        pop_msgBox.ShowOnPageLoad = true;
        gvAllocations.DataBind();
    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCourse.DataBind();
    }
    protected void txtRegStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (txtRegStatus.Text == "Pending")
        {
            cmdRegister.Text = "Register Selected";
            cmdRegister.ImageUrl = "~/COOPERP/images/tick-button.png";
        }
        else
        {
            cmdRegister.Text = "Remove Selected";
            cmdRegister.ImageUrl = "~/COOPERP/images/minus-button.png";
        }
    }
    protected void cmdRegister_Click(object sender, EventArgs e)
    {
        acad_GetCourseRegistrationListsTableAdapter REG = new acad_GetCourseRegistrationListsTableAdapter();
        for (int i = 0; i < gvAllocations.VisibleRowCount; i++)
        {
            if (gvAllocations.Selection.IsRowSelected(i))
            {
                lbl_msg.Text = REG.acad_CourseRegister(gvAllocations.GetRowValues(i, "regno").ToString(), txtCourse.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text),
                    "NORMAL", txtProgramme.Value.ToString(), HttpContext.Current.User.Identity.Name, txtRegStatus.Text).ToString();
            }
        }
        pop_msgBox.ShowOnPageLoad = true;
        gvAllocations.DataBind();
    }
}