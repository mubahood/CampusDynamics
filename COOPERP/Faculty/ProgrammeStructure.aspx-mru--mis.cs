using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Faculty_ProgrammeStructure : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //panel_progCourses.HeaderText = "COURSE STRUCTURE FOR "+Session["progname"]+" ["+Session["prog"]+"]";
        
    }
    protected void gvProgCourses_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["progcode"] = Session["prog"];
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        try
        {
            FacultyDataTableAdapters.acad_programmecoursesTableAdapter PROGCS = new FacultyDataTableAdapters.acad_programmecoursesTableAdapter();
            FacultyDataTableAdapters.acad_courseTableAdapter CS = new FacultyDataTableAdapters.acad_courseTableAdapter();

            int course_existance = int.Parse(CS.CheckCourseExistance(txtPrefix.Text).ToString());
            if (course_existance > 0)
            {
                PROGCS.Insert(Session["prog"].ToString(), txtPrefix.Text, 1, 1, int.Parse(txt_curriculums.Value.ToString()));
                lbl_response.Text = "Course Added Successfully.";
            }
            else
                lbl_response.Text = "The Entered Course Code doesn't exist. Please Check.";

            pop_response.ShowOnPageLoad = true;
            gvProgCourses.DataBind();
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("Duplicate"))
                lbl_response.Text = "Error! Course Already Exists on this Program Structure.";
            else
                lbl_response.Text = "Error! " + ex.Message;
            pop_response.ShowOnPageLoad = true;
        }
    }
    protected void cmdBatch_Click(object sender, EventArgs e)
    {
        FacultyDataTableAdapters.acad_programmecoursesTableAdapter PROGCS = new FacultyDataTableAdapters.acad_programmecoursesTableAdapter();
        PROGCS.acad_AddBatchCourses(txtPrefix.Text,Session["prog"].ToString(),int.Parse(txt_curriculums.Value.ToString()));
        gvProgCourses.DataBind();
    }
    
    protected void gv_scores_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int coursework = int.Parse(e.NewValues["Coursework"].ToString());
        int practicals = int.Parse(e.NewValues["Practicals"].ToString());
        int exam       = int.Parse(e.NewValues["Exams"].ToString());

        int TotalScore = coursework + practicals + exam;

        if (TotalScore != 100)
            throw new Exception("Total Ratio Score should be 100, Please Check entries");
    }

    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }

    protected void gv_scores_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = UnwrapExceptionMessage(e.Exception);
    }
    protected void gvProgSession_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void gvProgSession_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["progid"] = Session["prog"];
    }
    protected void cmdUpdateCurriculum_Click(object sender, EventArgs e)
    {
        int selectedrows = gvProgCourses.Selection.Count;
        if (selectedrows > 0)
        {
            txt_curriculums_new.Text = "";
            txt_curriculums_new.DataBind();
            pop_changeCurriculum.ShowOnPageLoad = true;
        }
        else
        {
            lbl_response.Text = "Please Select Course(s) to Switch Curriculums";
            pop_response.ShowOnPageLoad = true;
        }
    }
    protected void cmdChangeCurriculum_Click(object sender, EventArgs e)
    {
        int rows = gvProgCourses.VisibleRowCount, counter = 0;

        FacultyDataTableAdapters.acad_programmecoursesTableAdapter course = new FacultyDataTableAdapters.acad_programmecoursesTableAdapter();
        for (int i = 0; i < rows; i++)
        {
            if (gvProgCourses.Selection.IsRowSelected(i))
            {
                try
                {
                    course.UpdateCourseCurriculum(int.Parse(txt_curriculums_new.Value.ToString()), int.Parse(gvProgCourses.GetRowValues(i, "ID").ToString()));
                   
                    counter++;
                }
                catch (Exception ex) {
                    
                    lbl_response.Text = UnwrapExceptionMessage(ex);
                    pop_response.ShowOnPageLoad = true;
                    break;
                }
            }
        }
        gvProgCourses.DataBind();
        lbl_response.Text = counter + " Courses(s) Changed to " + txt_curriculums_new.Text;
        pop_changeCurriculum.ShowOnPageLoad = false;
        pop_response.ShowOnPageLoad = true;
    }
    protected void btn_print_Click(object sender, EventArgs e)
    {
        Session["Report"] = "Program Structures";
        //Session["prog"] = Session["prog"];
        Session["CurrID"] = txt_curriculums.Value;
        pop_details.ContentUrl = ResolveUrl("~/COOPERP/XtraReports/Default.aspx");
        pop_details.Width = 850;
        pop_details.Height = 500;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdAddNewCurriculum_Click(object sender, EventArgs e)
    {
        gvCurriculumInfo.AddNewRow();
    }
    protected void gvCurriculumInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = UnwrapExceptionMessage(e.Exception);
    }
    protected void gvCurriculumInfo_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        e.NewValues["progcode"] = Session["prog"];
    }
    protected void gvProgCourses_RowInserted(object sender, DevExpress.Web.Data.ASPxDataInsertedEventArgs e)
    {
        //ds_curriculum.Select();
        txt_curriculums.DataBind();
        gvProgCourses.DataBind();
    }
}