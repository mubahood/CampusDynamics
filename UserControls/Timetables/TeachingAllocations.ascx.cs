using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_TeachingAllocations : System.Web.UI.UserControl
{
    // Fix DevExpress v16.1 bug: batch-edit grid pager emits 'pageSizeChanged': with no value,
    // causing a SyntaxError that crashes the entire DX init chain on the page.
    protected override void Render(System.Web.UI.HtmlTextWriter writer)
    {
        System.IO.StringWriter sw = new System.IO.StringWriter();
        System.Web.UI.HtmlTextWriter hw = new System.Web.UI.HtmlTextWriter(sw);
        base.Render(hw);
        string html = sw.ToString();
        // Replace the broken: 'pageSizeChanged':\n  with  'pageSizeChanged': null\n
        html = System.Text.RegularExpressions.Regex.Replace(
            html,
            @"'pageSizeChanged':\s*\r?\n",
            "'pageSizeChanged': null\n");
        writer.Write(html);
    }

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
            txtCampus.SelectedIndex = 0;
            gvAllocations.Enabled = false;
            txt_new_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_new_entry_year.DataBind();
        }
       
        
        
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
try{
         if (int.Parse(txtCampus.Value.ToString()) != 0)
         {
        TimetableDataTableAdapters.acad_teaching_allocationTableAdapter ALLOC = new TimetableDataTableAdapters.acad_teaching_allocationTableAdapter();
        ALLOC.Insert(txtLecturer.Value.ToString(), txtCourse.Value.ToString(), txtAcad.Text, int.Parse(txtSemester.Text), txtProgramme.Value.ToString(),
            int.Parse(txtStudyYear.Text), txtsession.Text, txtintake.Text, "-",int.Parse(txtCampus.Value.ToString()),"-",int.Parse(txt_entry_year.Text));
        lbl_msg.Text = "Blank Allocation Added. Please Edit";
        pop_msgBox.ShowOnPageLoad = true;
        gvAllocations.DataBind();
    }
    else
        {
            lbl_msg.Text = "Please Select a Campus";
            pop_msgBox.ShowOnPageLoad = true;
        }
}
catch(Exception ex)
{
  lbl_msg.Text = "Error: Make Sure Course is Selected";
            pop_msgBox.ShowOnPageLoad = true;
}
    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCourse.DataBind();
    }
    protected void txtLecturer_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvAllocations.DataBind();
    }
    protected void txtCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (int.Parse(txtCampus.Value.ToString()) == 0)
        {
            gvAllocations.Enabled = false;
            
        }
        else
        {
            gvAllocations.Enabled = true;
            
        }
    }
    protected void gvAllocations_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Contains("Exception has been thrown by the target of an invocation."))
        {
            e.ErrorText = e.Exception.InnerException.Message;
                //"Possible Room Collision detected. Please Check Timetable Entries.";
        }
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = "Teaching Allocations";
        Session["prog"] = txtProgramme.Value;
        Session["acad"] = txtAcad.Text;
        Session["sems"] = txtSemester.Text;
        Session["cyear"] = txtStudyYear.Text;
        Session["intake"] = txtintake.Text;
        Session["sess"] = txtsession.Text;
        Session["campusno"] = txtCampus.Value;
        Session["EntYr"] = txt_entry_year.Text;

        pop_print.ContentUrl = "~/COOPERP/Timetables/XtraReports/Default.aspx";
        pop_print.Height = 600;
        pop_print.Width = 900;
        pop_print.ShowOnPageLoad = true;

    }

    protected void cmdAdopt_Click(object sender, EventArgs e)
    {
       
        pop_adopt.ShowOnPageLoad = true;
    }
    protected void cmdAdoptAllocation_Click(object sender, EventArgs e)
    {
        try
        {
            if (int.Parse(txtCampus.Value.ToString()) != 0 && txtProgramme.Value.ToString() != "-" && txtintake.Text != "-" && txtsession.Text != "-")
            {
                TimetableDataTableAdapters.acad_teaching_allocationTableAdapter ALLOC = new TimetableDataTableAdapters.acad_teaching_allocationTableAdapter();
                ALLOC.AdoptTimeTable(txtProgramme.Value.ToString(),txtAcad.Text,txtSemester.Text,txtStudyYear.Text,txt_entry_year.Text,txtintake.Text,txtsession.Text,txtCampus.Value.ToString(),
                    txt_new_entry_year.Text);
                txt_entry_year.Text = txt_new_entry_year.Text;
                pop_adopt.ShowOnPageLoad = false;
                lbl_msg.Text = "Allocation Added. Please Edit if necessary";
                pop_msgBox.ShowOnPageLoad = true;
                gvAllocations.DataBind();
            }
            else
            {
                lbl_msg.Text = "Error: Please Select a Campus, Programme, Study Session and In-take.";
                pop_adopt.ShowOnPageLoad = false;
                pop_msgBox.ShowOnPageLoad = true;
            }
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error: " + ex.Message;
            pop_msgBox.ShowOnPageLoad = true;
        }
    }
}