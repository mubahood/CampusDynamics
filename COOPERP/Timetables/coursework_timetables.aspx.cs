using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Timetables_coursework_timetables : System.Web.UI.Page
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
            gvCoursework.Enabled = false;
            cbx_campus.SelectedIndex = 1;
            txtAcadyear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadyear.DataBind();
            txtAcadyear.Text = SettingsFile.ReturnDefaultAcademicYr();
            txtAcadyear.Value = SettingsFile.ReturnDefaultAcademicYr();
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }

    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        if (int.Parse(txtCampus.Value.ToString()) != 0)
        {
            TimetableDataTableAdapters.acad_coursework_timetableTableAdapter ALLOC = new TimetableDataTableAdapters.acad_coursework_timetableTableAdapter();
            ALLOC.Insert(txtLecturer.Value.ToString(), txtCourse.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text), txtProgramme.Value.ToString(),
                int.Parse(txtStudyYear.Text), txtsession.Text, txtintake.Text, "-", int.Parse(txtCampus.Value.ToString()));
            lbl_msg.Text = "Entry Added. Please Edit";
            pop_msgBox.ShowOnPageLoad = true;
            gvCoursework.DataBind();
        }
        else
        {
            lbl_msg.Text = "Please Select a Campus";
            pop_msgBox.ShowOnPageLoad = true;
        }

    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCourse.DataBind();
    }
    protected void txtLecturer_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvCoursework.DataBind();
    }
    protected void cmdAddBatch_Click(object sender, EventArgs e)
    {
        if (int.Parse(txtCampus.Value.ToString()) != 0)
        {
            TimetableDataTableAdapters.acad_coursework_timetableTableAdapter ALLOC = new TimetableDataTableAdapters.acad_coursework_timetableTableAdapter();
            ALLOC.AddBatchCourses(txtProgramme.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text),
                int.Parse(txtStudyYear.Text), int.Parse(txtCampus.Value.ToString()),"-","-",0);
            lbl_msg.Text = "Batch Courses Added, Please Edit Dates";
            pop_msgBox.ShowOnPageLoad = true;
            gvCoursework.DataBind();
        }
        else
        {
            lbl_msg.Text = "Please Select a Campus";
            pop_msgBox.ShowOnPageLoad = true;
        }

    }
    protected void txtCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (int.Parse(txtCampus.Value.ToString()) == 0)
        {
            gvCoursework.Enabled = false;

        }
        else
        {
            gvCoursework.Enabled = true;

        }
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = "Coursework Timetable";
        Session["prog"] = txtProgramme.Value;
        Session["acad"] = txtAcad.Text;
        Session["sems"] = txtSemester.Text;
        Session["cyear"] = txtStudyYear.Text;
        Session["intake"] = txtintake.Text;
        Session["sess"] = txtsession.Text;
        Session["campusno"] = txtCampus.Value;

        pop_print.ContentUrl = "~/COOPERP/Timetables/XtraReports/Default.aspx";
        pop_print.Height = 600;
        pop_print.Width = 900;
        pop_print.ShowOnPageLoad = true;
    }
    protected void btn_add_Click(object sender, EventArgs e)
    {
        if (int.Parse(cbx_campus.Value.ToString()) != 0)
            gv_ratios.AddNewRow();
        else
        {
            lbl_msg.Text = "Please Select a Campus.";
            pop_msgBox.ShowOnPageLoad = true;
        }
    }
    protected void gv_ratios_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["campusID"] = uint.Parse(cbx_campus.Value.ToString());
        e.NewValues["acadyear"] = txtAcadyear.Text;
    }
    protected void txtAcadyear_SelectedIndexChanged(object sender, EventArgs e)
    {
        gv_ratios.DataBind();
    }

    protected void gv_ratios_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height= 30;
    }

    protected void gv_ratios_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Contains("Exception has been thrown by the target of an invocation."))
            e.ErrorText = e.Exception.InnerException.Message;
    }
    
}