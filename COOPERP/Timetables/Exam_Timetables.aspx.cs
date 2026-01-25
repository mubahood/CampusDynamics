using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Timetables_Exam_Timetables : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcad.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcad.DataBind();
            txtAcad.Text = SettingsFile.ReturnDefaultAcademicYr();
            pop_msgBox.HeaderText = SettingsFile.AppName;
            txtCampus.SelectedIndex = 0;
            gvExams.Enabled = false;
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }

    }

    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        try{
        if (int.Parse(txtCampus.Value.ToString()) != 0)
        {
            TimetableDataTableAdapters.acad_exam_timetableTableAdapter ALLOC = new TimetableDataTableAdapters.acad_exam_timetableTableAdapter();
            TimetableDataTableAdapters.acad_InitialiseExaminationPaperSettingsTableAdapter settings = new TimetableDataTableAdapters.acad_InitialiseExaminationPaperSettingsTableAdapter();

            ALLOC.Insert(txtLecturer.Value.ToString(), txtCourse.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text), txtProgramme.Value.ToString(),
                int.Parse(txtStudyYear.Text), txtsession.Text, txtintake.Text, "-",int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString()),txt_examtyp.Text);
            settings.GetData("-", txtAcad.Text, int.Parse(txtSemester.Text),txt_examtyp.Text);
            lbl_msg.Text = "Entry Added. Please Edit";
            pop_msgBox.ShowOnPageLoad = true;
            gvExams.DataBind();
        }
        else
        {
            lbl_msg.Text = "Please Select a Campus";
            pop_msgBox.ShowOnPageLoad = true;
        }
        }
       catch(Exception ex)
        {
            lbl_msg.Text = UnwrapExceptionMessage(ex);
            pop_msgBox.ShowOnPageLoad = true;
        }

    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCourse.DataBind();
    }
    protected void txtLecturer_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvExams.DataBind();
    }
    protected void cmdAddBatch_Click(object sender, EventArgs e)
    {
        try
        {
            if (int.Parse(txtCampus.Value.ToString()) != 0)
            {
                TimetableDataTableAdapters.acad_exam_timetableTableAdapter ALLOC = new TimetableDataTableAdapters.acad_exam_timetableTableAdapter();
                ALLOC.AddBatchExams(txtProgramme.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text),
                    int.Parse(txtStudyYear.Text), int.Parse(txtCampus.Value.ToString()), txtintake.Text, txtsession.Text, int.Parse(txt_entry_year.Value.ToString()));
                gvExams.DataBind();
                int rows = gvExams.VisibleRowCount;
                if (rows > 0)
                    lbl_msg.Text = "Batch Courses Added, Please Edit Dates";
                else
                    lbl_msg.Text = "Selected Programme does not have Timetable Allocations.";

                pop_msgBox.ShowOnPageLoad = true;

            }
            else
            {
                lbl_msg.Text = "Please Select a Campus";
                pop_msgBox.ShowOnPageLoad = true;
            }
        }
        catch(Exception ex)
        {
            lbl_msg.Text = UnwrapExceptionMessage(ex);
            pop_msgBox.ShowOnPageLoad = true;
        }

    }
    protected void txtCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (int.Parse(txtCampus.Value.ToString()) == 0)
        {
            gvExams.Enabled = false;

        }
        else
        {
            gvExams.Enabled = true;

        }
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = "Exam Timetable";
        Session["fac"] = txtFaculty.Value;
        Session["prog"] = txtProgramme.Value;
        Session["acad"] = txtAcad.Text;
        Session["sems"] = txtSemester.Text;
        Session["cyear"] = txtStudyYear.Text;
        Session["intake"] = txtintake.Text;
        Session["sess"] = txtsession.Text;
        Session["entyr"] = txt_entry_year.Text;
        Session["campusno"] = txtCampus.Value;
        Session["exmtyp"] = txt_examtyp.Text;

        pop_print.ContentUrl = "~/COOPERP/Timetables/XtraReports/Default.aspx";
        pop_print.Height = 600;
        pop_print.Width = 900;
        pop_print.ShowOnPageLoad = true;
    }
    protected void gvExams_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        TimetableDataTableAdapters.acad_InitialiseExaminationPaperSettingsTableAdapter settings = new TimetableDataTableAdapters.acad_InitialiseExaminationPaperSettingsTableAdapter();
        settings.GetData("-", txtAcad.Text, int.Parse(txtSemester.Text), txt_examtyp.Text);
    }
}