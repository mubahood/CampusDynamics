using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Timetables_CourseRegistrationSelections : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcad.DataSource = SettingsFile.ReturnAcademicYrs();
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
            txtAcad.DataBind();
            txtAcad.Text = SettingsFile.ReturnDefaultAcademicYr();
            pop_msgBox.HeaderText = SettingsFile.AppName;

            txt_new_acadyr.DataSource = SettingsFile.ReturnAcademicYrs();
            txt_new_acadyr.DataBind();
        }



    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        try
        {
             TimetableDataTableAdapters.acad_teaching_allocation_for_registrationTableAdapter ALLOC = new TimetableDataTableAdapters.acad_teaching_allocation_for_registrationTableAdapter();

             if (txtintake.Text != "-")
             {

                 ALLOC.Insert(txtCourse.Value.ToString(), txtAcad.Text, uint.Parse(txtSemester.Text), txtProgramme.Value.ToString(),
                     uint.Parse(txtStudyYear.Text),"-", txtintake.Text, "-", uint.Parse(txt_entry_year.Text));

                 lbl_msg.Text = "Course Added Successfully";
                 gvAllocations.DataBind();
             }
             else
                 lbl_msg.Text = "Please Select an Intake and a Session.";

                pop_msgBox.ShowOnPageLoad = true;
                
           
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("Duplicate"))
                lbl_msg.Text = "Error: Course Already Selected for the specified Period";
            else
            lbl_msg.Text = "Error: Make Sure Course is Selected";
            pop_msgBox.ShowOnPageLoad = true;
        }
    }

    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCourse.DataBind();
    }

    protected void gvAllocations_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Contains("Exception has been thrown by the target of an invocation."))
        {
            e.ErrorText = e.Exception.InnerException.Message;
            //"Possible Room Collision detected. Please Check Timetable Entries.";
        }
    }

protected void cmdAdopt_Click(object sender, EventArgs e)
    {
       
        pop_adopt.ShowOnPageLoad = true;
    }
protected void cmdAdoptAllocation_Click(object sender, EventArgs e)
{
    try
    {
        
            TimetableDataTableAdapters.acad_teaching_allocation_for_registrationTableAdapter ALLOC = new TimetableDataTableAdapters.acad_teaching_allocation_for_registrationTableAdapter();
           string Selections = ALLOC.AdoptCourseSelections(txtAcad.Text, int.Parse(txtSemester.Text), txt_new_acadyr.Text,int.Parse(txt_New_sem.Text)).ToString();
            
            pop_adopt.ShowOnPageLoad = false;

            if(int.Parse(Selections) == 0)
                lbl_msg.Text = "Adoption didn\'t make any Changes.";
            else

            lbl_msg.Text = "Adoption Completed Successfully. " + Selections + " Course Selections Added." ;
            pop_msgBox.ShowOnPageLoad = true;
            gvAllocations.DataBind();
       
    }
    catch (Exception ex)
    {
        lbl_msg.Text = "Error: " + ex.Message;
        pop_msgBox.ShowOnPageLoad = true;
    }
}

protected void cmdRegister_Click(object sender, EventArgs e)
{
    try
    {
        TimetableDataTableAdapters.acad_teaching_allocation_for_registrationTableAdapter ALLOC = new TimetableDataTableAdapters.acad_teaching_allocation_for_registrationTableAdapter();

        int noRows = gvAllocations.VisibleRowCount;
        if (string.IsNullOrEmpty(noRows.ToString()))
            noRows = 0;
        if (txtintake.Text == "-")
        {
            lbl_msg.Text = "Error: Please Select an appropriate Intake for Student Registration.";
        }
        else if (noRows == 0)
        {
            lbl_msg.Text = "Error: There are no Selected Courses.";
        }

        else
        {
            for (int i = 0; i < noRows; i++)
            {
                string course = gvAllocations.GetRowValues(i, "courseID").ToString();

                ALLOC.BatchCourseRegistration(course, txtAcad.Text, txtSemester.Text, txtProgramme.Value.ToString(), txt_entry_year.Text, txtintake.Text);
            }
            lbl_msg.Text = "Course Registration Successfull.";
        }

        pop_msgBox.ShowOnPageLoad = true;
    }
    catch (Exception ex)
    {
        lbl_msg.Text = "Error: " + ex.Message;
        pop_msgBox.ShowOnPageLoad = true;
    }
}
}