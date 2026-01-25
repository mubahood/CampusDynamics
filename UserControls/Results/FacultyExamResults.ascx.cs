using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ResultsDataTableAdapters;
using SecurityTableAdapters;

public partial class UserControls_Results_FacultyExamResults : System.Web.UI.UserControl
{
    acad_activity_logTableAdapter sec_log = new acad_activity_logTableAdapter();
    acad_examresults_faculty_settingsTableAdapter setting = new acad_examresults_faculty_settingsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
            pop_messagebox.HeaderText = SettingsFile.AppName;
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();


           // txtCourse.Value = "ACC";
            txtCampus.Value = 1;
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }
        if (HttpContext.Current.User.IsInRole("Dean") || HttpContext.Current.User.IsInRole("Administrator"))
        {
            cmdApprove.Enabled = true;
            cmdCancelApprove.Enabled = true;
        }

        //if (string.IsNullOrEmpty(txtCourse.Value.ToString()))
           
       // if (string.IsNullOrEmpty(txtCampus.Value.ToString()))
            
        //if (string.IsNullOrEmpty(txt_entry_year.Text))


      

    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        String comm = "No Pending Results Selected";
        int noRows = gvMarksheet.VisibleRowCount, counter = 0;
        ResultsDataTableAdapters.acad_examresults_facultyTableAdapter EXM = new ResultsDataTableAdapters.acad_examresults_facultyTableAdapter();

        if (HttpContext.Current.User.IsInRole("Dean"))
        {
            for (int i = 0; i < noRows; i++)
            {
                if (gvMarksheet.Selection.IsRowSelected(i) && gvMarksheet.GetRowValues(i, "approved_by").ToString() == "-")
                {
                    try
                    {

                        EXM.acad_CaptureFacultyResults(HttpContext.Current.User.Identity.Name.ToString(),
                        gvMarksheet.GetRowValues(i, "regno").ToString(), txtCourse.Value.ToString(), txtAcadYear.Text, txtSemester.Text,
                        int.Parse(gvMarksheet.GetRowValues(i, "total_mark").ToString()), int.Parse(txtStudyYear.Text),
                        int.Parse(gvMarksheet.GetRowValues(i, "ID").ToString()), txtExamStatus.Text);
                        counter++;
                        comm = counter + " Result(s) Approved";

                    }
                    catch (Exception ex)
                    {
                        comm = "Error!" + ex.Message;

                    }
                }

            }
        }
        else
        {
            comm = "Results Approvals can only be done by the Dean.";
        }
        gvMarksheet.DataBind();
        lbl_msg.Text = comm;
        pop_msgBox.ShowOnPageLoad = true;

    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        

        pop_details.ContentUrl = "~/COOPERP/Results/MarkSheetDetails.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        GVE_Marksheets.WriteXlsToResponse(string.Format("{2} MarksheetList {0}_{1}", txtAcadYear.Text, txtSemester.Text, txtExamStatus.Text), 
            new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    protected void cmdStatusChange_Click(object sender, EventArgs e)
    {
        ResultsDataTableAdapters.acad_examsettingsTableAdapter EX = new ResultsDataTableAdapters.acad_examsettingsTableAdapter();
        lbl_comment.Text = "Status Updated";
    }

    void StatusUpdater()
    {
       

    }
    
    protected void gvMarksheet_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        if (e.OldValues["approved_by"].ToString() != "-")
        {
            e.NewValues["cw_mark_entered"] = e.OldValues["cw_mark_entered"];
            e.NewValues["test_mark_entered"] = e.OldValues["test_mark_entered"];
            e.NewValues["ex_mark_entered"] = e.OldValues["ex_mark_entered"];
            throw new Exception("Approved Results Can not be Edited. \nCheck Student: [" + e.OldValues["regno"] + "]");
        }
        else
        {
            string courseworkratio = setting.GetCourseWorkRatio(txtCourse.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtProg.Value.ToString(), txtSession.Text, int.Parse(txtStudyYear.Text),
                            txtintake.Text, int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString())).ToString();
            string testratio = setting.GetTestRatio(txtCourse.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtProg.Value.ToString(), txtSession.Text, int.Parse(txtStudyYear.Text),
                                 txtintake.Text, int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString())).ToString();
            string examratio = setting.GetExamRatio(txtCourse.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtProg.Value.ToString(), txtSession.Text, int.Parse(txtStudyYear.Text),
                                 txtintake.Text, int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString())).ToString();
            if (!string.IsNullOrEmpty(courseworkratio))
                e.NewValues["cw_mark"] = Math.Round(decimal.Parse(e.NewValues["cw_mark_entered"].ToString()) * decimal.Parse(courseworkratio) / 100, 0);
            else
                throw new Exception("Mark Ratios have not been Set.");

            if (!string.IsNullOrEmpty(testratio))
                e.NewValues["test_mark"] = Math.Round(decimal.Parse(e.NewValues["test_mark_entered"].ToString()) * decimal.Parse(testratio) / 100, 0);

            if (!string.IsNullOrEmpty(examratio))
                e.NewValues["ex_mark"] = Math.Round(decimal.Parse(e.NewValues["exam_mark_entered"].ToString()) * decimal.Parse(examratio) / 100,0);
            else
                throw new Exception("Mark Ratios have not been Set.");

            e.NewValues["total_mark"] = int.Parse(e.NewValues["cw_mark"].ToString()) + int.Parse(e.NewValues["test_mark"].ToString()) + int.Parse(e.NewValues["ex_mark"].ToString());

            if(int.Parse(e.NewValues["total_mark"].ToString())>100)
                throw new Exception("Total Mark is incorrect for student: [ " + e.OldValues["regno"] +" ]");

            /*if (int.Parse(e.NewValues["total_mark"].ToString()) >= 45 && int.Parse(e.NewValues["total_mark"].ToString()) <= 50)
                e.NewValues["total_mark"] = 50;*/

        }
    }
    protected void cmdCancelApprove_Click(object sender, EventArgs e)
    {
        int noRows = gvMarksheet.VisibleRowCount,counter=0;
        ResultsDataTableAdapters.acad_examresults_facultyTableAdapter EXM = new ResultsDataTableAdapters.acad_examresults_facultyTableAdapter();
        
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheet.Selection.IsRowSelected(i) && gvMarksheet.GetRowValues(i, "approved_by").ToString()!="-")
            {
                //if (gvMarksheet.GetRowValues(i, "approved_by").ToString() != HttpContext.Current.User.Identity.Name.ToString() && gvMarksheet.GetRowValues(i, "approved_by").ToString()!="-")
                //{
                //    lbl_msg.Text = "Cancelation Denied. You can not cancel another user's Approvals.";
                //    break;
                //}
                //else 
                if (!HttpContext.Current.User.IsInRole("Dean"))
                {
                    lbl_msg.Text = "Cancelation Denied. Only the Dean can cancel approvals.";
                    break;
                }
                else
                {
                    counter++;
                    EXM.UpdateApprovalStatus(HttpContext.Current.User.Identity.Name,"-", int.Parse(gvMarksheet.GetRowValues(i, "ID").ToString()));
                    lbl_msg.Text = counter + " Results Approvals Cancelled";
                }
            }
        }
        gvMarksheet.DataBind();
        pop_msgBox.ShowOnPageLoad = true;
    }



    protected void cmdPrintSheet_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        Session["prog"] = txtProg.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sems"] = txtSemester.Text;
        Session["Report"] = "Faculty Marksheet";

        Session["csid"]=txtCourse.Value;
        Session["sess"]=txtSession.Text;
        Session["yr"]=txtStudyYear.Text;
         Session["stat"]=txtExamStatus.Text;
         Session["intak"] = txtintake.Text;
         Session["entyr"] = txt_entry_year.Text;
         Session["campus"] = txtCampus.Value;
        pop_details.ShowOnPageLoad = true;

    }



    protected void cmdCreateSheet_Click(object sender, EventArgs e)
    {
        try
        {
            ResultsDataTableAdapters.acad_examresults_facultyTableAdapter EXM = new ResultsDataTableAdapters.acad_examresults_facultyTableAdapter();
            EXM.acad_CreateFacultyExamSheet(txtProg.Value.ToString(), int.Parse(txtSemester.Text), int.Parse(txtStudyYear.Text), txtSession.Text, txtAcadYear.Text,
                txtCourse.Value.ToString(), txtExamStatus.Text,txtintake.Text,txt_entry_year.Text,txtCampus.Value.ToString(),txt_courseworkratio.Text,txt_examratio.Text,txt_testratio.Text);
           
            gvMarksheet.DataBind();

            if(gvMarksheet.VisibleRowCount == 0)
                lbl_msg.Text = "Resultsheet Empty. No Registered Students.";
            else
                lbl_msg.Text = "Resultsheet Refresh Completed";

            pop_messagebox.ShowOnPageLoad = false;
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("Object reference not set to an instance of an object."))
                lbl_msg.Text = "Resultsheet Refresh Error! Try Again [ Make Sure all fields are Selected ]";
            else
                if (ex.Message.Contains("Exception has been thrown by the target of an invocation."))
                    lbl_msg.Text = "Resultsheet Refresh Error! Try Again [" + ex.InnerException.Message + "]";
                else

                   lbl_msg.Text = "Resultsheet Refresh Error! Try Again [" + ex.Message + "]";
        }
        pop_msgBox.ShowOnPageLoad = true;
    }
    
    protected void cmddisplayratios_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(txtCourse.Value.ToString()))
                txtCourse.Value = "-";
            string courseworkratio = setting.GetCourseWorkRatio(txtCourse.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtProg.Value.ToString(), txtSession.Text, int.Parse(txtStudyYear.Text),
                                txtintake.Text, int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString())).ToString();

            string testratio = setting.GetTestRatio(txtCourse.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtProg.Value.ToString(), txtSession.Text, int.Parse(txtStudyYear.Text),
                                txtintake.Text, int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString())).ToString();

            string examratio = setting.GetExamRatio(txtCourse.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtProg.Value.ToString(), txtSession.Text, int.Parse(txtStudyYear.Text),
                                 txtintake.Text, int.Parse(txt_entry_year.Text), int.Parse(txtCampus.Value.ToString())).ToString();
            if (!string.IsNullOrEmpty(courseworkratio))
                txt_courseworkratio.Text = courseworkratio;
            else
                txt_courseworkratio.Text = "0";

            if (!string.IsNullOrEmpty(testratio))
                txt_testratio.Text = testratio;
            else
                txt_testratio.Text = "0";

            if (!string.IsNullOrEmpty(examratio))
                txt_examratio.Text = examratio;
            else
                txt_examratio.Text = "0";
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error: Make sure the Course is Selected. " + ex.Message;  
        }
    }
    
    protected void gvMarksheet_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Contains("Exception has been thrown by the target of an invocation."))
            e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void cmdPrintBlankCourseWorkSheet_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        //Session["prog"] = txtProg.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sems"] = txtSemester.Text;
        Session["Report"] = "Blank CourseWork Marksheet";

        //Session["csid"] = txtCourse.Value;
        //Session["sess"] = txtSession.Text;
        Session["yr"] = txtStudyYear.Text;
        //Session["stat"] = txtExamStatus.Text;
       Session["intak"] = txtintake.Text;
       Session["entyr"] = txt_entry_year.Text;
        Session["campus"] = txtCampus.Value;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdPrintBlankExamSheet_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        //Session["prog"] = txtProg.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sems"] = txtSemester.Text;
        Session["Report"] = "Blank Exam Marksheet";

       // Session["csid"] = txtCourse.Value;
        //Session["sess"] = txtSession.Text;
        Session["yr"] = txtStudyYear.Text;
        //Session["stat"] = txtExamStatus.Text;
        Session["intak"] = txtintake.Text;
        Session["entyr"] = txt_entry_year.Text;
        Session["campus"] = txtCampus.Value;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdPrintInternshipSheet_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        //Session["prog"] = txtProg.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sems"] = txtSemester.Text;
        Session["Report"] = "Blank Internship Marksheet";

        //Session["csid"] = txtCourse.Value;
        //Session["sess"] = txtSession.Text;
        Session["yr"] = txtStudyYear.Text;
        //Session["stat"] = txtExamStatus.Text;
        Session["intak"] = txtintake.Text;
        Session["entyr"] = txt_entry_year.Text;
        Session["campus"] = txtCampus.Value;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdPrintBlankResearchSheet_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        //Session["prog"] = txtProg.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sems"] = txtSemester.Text;
        Session["Report"] = "Blank Research Marksheet";

        //Session["csid"] = txtCourse.Value;
        //Session["sess"] = txtSession.Text;
        Session["yr"] = txtStudyYear.Text;
        //Session["stat"] = txtExamStatus.Text;
        Session["intak"] = txtintake.Text;
        Session["entyr"] = txt_entry_year.Text;
        Session["campus"] = txtCampus.Value;
        pop_details.ShowOnPageLoad = true;
    }
    protected void txtProg_SelectedIndexChanged1(object sender, EventArgs e)
    {
        txtCourse.DataBind();
    }
    protected void gvMarksheet_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        if (e.Values["approved_by"].ToString() != "-")
            //Response.Write(e.Values["approved_by"].ToString());
            throw new Exception("Results Already Approved. Deletion Denied");
    }

    protected void gvMarksheet_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        try
        {
            string ipaddress = GetClientIPAddress();

            // Safe value retrieval with conditional operator
            string student = e.OldValues["regno"] != null ? e.OldValues["regno"].ToString() : "Unknown";

            string Course = txtCourse.Value != null ? txtCourse.Value.ToString() : "Unknown";
            string AcademicYear = !string.IsNullOrEmpty(txtAcadYear.Text) ? txtAcadYear.Text : "Unknown";
            string Semester = !string.IsNullOrEmpty(txtSemester.Text) ? txtSemester.Text : "Unknown";

            string OldCourseWork = e.OldValues["cw_mark_entered"] != null ? e.OldValues["cw_mark_entered"].ToString() : "";
            string NewCourseWork = e.NewValues["cw_mark_entered"] != null ? e.NewValues["cw_mark_entered"].ToString() : "";
            string OldTestMark = e.OldValues["test_mark_entered"] != null ? e.OldValues["test_mark_entered"].ToString() : "";
            string NewTestMark = e.NewValues["test_mark_entered"] != null ? e.NewValues["test_mark_entered"].ToString() : "";
            string OldExamMark = e.OldValues["exam_mark_entered"] != null ? e.OldValues["exam_mark_entered"].ToString() : "";
            string NewExamMark = e.NewValues["exam_mark_entered"] != null ? e.NewValues["exam_mark_entered"].ToString() : "";

            sec_log.Insert(
                HttpContext.Current.User.Identity.Name,
                "Faculty Exam Results Editor",
                "Student: " + student + " Course: " + Course +
                " Academic Year: " + AcademicYear + " Semester: " + Semester + " Old CourseWork Mark: " + OldCourseWork +
                " New CourseWork: " + NewCourseWork + " Old Test Mark: " + OldTestMark + " New Test Mark: " + NewTestMark +
                " Old Exam Mark: " + OldExamMark + " New Exam Mark: " + NewExamMark + " IP Address: " + ipaddress,
                "Changed Student Marks",
                DateTime.Now
            );
        }
        catch (Exception ex)
        {
            // Log the error if something still goes wrong
            sec_log.Insert(
                "SYSTEM",
                "Error",
                "Error in gvMarksheet_RowUpdated: " + ex.Message,
                "Error",
                DateTime.Now
            );
        }
    }

    protected string GetClientIPAddress()
    {
        // Look for a proxy address first
        string ip = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];

        // If no proxy, get the standard remote address
        if (string.IsNullOrEmpty(ip))
        {
            ip = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
        }
        else
        {
            // Extract first IP if multiple addresses are listed
            ip = ip.Split(',')[0].Trim();
        }

        // Handle localhost case
        if (ip == "::1")
        {
            ip = "127.0.0.1";
        }

        return ip;
    }
}