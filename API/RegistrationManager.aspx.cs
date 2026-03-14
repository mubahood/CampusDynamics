using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using StudentAccountingDataTableAdapters;


public partial class API_RegistrationManager : System.Web.UI.Page
{
    fin_GetClearanceListsTableAdapter clearance = new fin_GetClearanceListsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        PortalContentTableAdapters.acad_course_registrationTableAdapter CS = new PortalContentTableAdapters.acad_course_registrationTableAdapter();
        lbl_study_details.Text = string.Format("{0}, SEM|QTER {1} | YEAR {2}", Request["acadyear"], Request["sem"], Request["cyear"]);
        lbl_regStat.Text = "" + Request["regstat"];
        if (Request["regstat"] == "REGISTERED")
        {
            lbl_reg_comment.Text = "REGISTRATION DONE";
            cmdRegister.Visible = false;
        }
        else
        {
            lbl_reg_comment.Text = "REGISTRATION PENDING";
            cmdRegister.Visible = true;
        }
        lbl_bal_comment.Text = CS.GetCurrentBalance(Request["reg"]).ToString();

        //Bill Student if Necessary and Display Exam Permit Print button if student is CLEARED
        //string exam_clearance_Initial_stat = clearance.GetStudentClearanceStatus(Request["reg"].ToString(), int.Parse(Request["sem"].ToString()), Request["acadyear"].ToString()).ToString();

        //if (exam_clearance_Initial_stat != "CLEARED" && exam_clearance_Initial_stat != "PRINTED")

        //    clearance.GetStudentClearance(Request["reg"].ToString(), Request["sem"].ToString(), Request["acadyear"].ToString(), Request["reg"].ToString()).ToString();

        string exam_clearance_stat = clearance.GetStudentClearanceStatus(Request["reg"].ToString(), int.Parse(Request["sem"].ToString()), Request["acadyear"].ToString()).ToString();
        if (exam_clearance_stat == "CLEARED" || exam_clearance_stat == "PRINTED")
            cmdPrintExamPermit.Visible = true;
        else
            cmdPrintExamPermit.Visible = false;
        //Response.Write(exam_clearance_stat);
    }
    protected void gvCourseRegistration_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdCourseUnits_Click(object sender, EventArgs e)
    {
        gvPendingCourses.DataBind();
        lbl_cs_reg_comment.Text = "";
        pop_pending.Height = 500;
        pop_pending.ShowOnPageLoad = true;
    }
    protected void cmdRegisterCourse_Click(object sender, EventArgs e)
    {
        PortalContentTableAdapters.acad_course_registrationTableAdapter CS = new PortalContentTableAdapters.acad_course_registrationTableAdapter();
        PortalContentTableAdapters.acc_redo_infoTableAdapter RT = new PortalContentTableAdapters.acc_redo_infoTableAdapter();
        StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
        string prog = STUD.GetStudProgramme(Request["reg"]);
        string sess = STUD.GetStudSession(Request["reg"]);
        int counter = 0;

        int noRows = gvPendingCourses.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvPendingCourses.Selection.IsRowSelected(i))
            {
                counter++;
                CS.Insert(Request["reg"], gvPendingCourses.GetRowValues(i, "courseID").ToString(), Request["acadyear"], uint.Parse(Request["sem"]), txtCategory.Value.ToString(), prog, sess);
                if (txtCategory.Value.ToString() == "Retake")
                    RT.RegisterRetakeCourse(Request["reg"], gvPendingCourses.GetRowValues(i, "courseID").ToString(), uint.Parse(Request["sem"]), Request["acadyear"].ToString(),HttpContext.Current.User.Identity.Name);
                       
            }
        }
        lbl_cs_reg_comment.Text = counter+" Course(s) Registered";
        gvCourseRegistration.DataBind();
        gvPendingCourses.DataBind();
    }
    protected void cmdRegister_Click(object sender, EventArgs e)
    {
        try
        {
            if (gvCourseRegistration.VisibleRowCount > 0)
            {
                PortalContentTableAdapters.acad_StudentRegistrationTableAdapter REG = new PortalContentTableAdapters.acad_StudentRegistrationTableAdapter();
                string comm=REG.ProcessRegister(Request["reg"], Request["acadyear"], int.Parse(Request["sem"]), HttpContext.Current.User.Identity.Name).ToString();
                if(comm.Contains("1 Bill")) comm="Registration Completed Successfully";
                // Auto-bill student after registration
                fin_GetStudentFeesTrackListTableAdapter BILLING = new fin_GetStudentFeesTrackListTableAdapter();
                BILLING.fin_Autobilling(Request["reg"], Request["acadyear"], int.Parse(Request["sem"]), "REG", HttpContext.Current.User.Identity.Name, "-");
                BILLING.fin_Autobilling(Request["reg"], Request["acadyear"], int.Parse(Request["sem"]), "ACCOMO", HttpContext.Current.User.Identity.Name, "-");
                // --- Update labels and button dynamically ---
                lbl_regStat.Text = "REGISTERED";
                lbl_reg_comment.Text = "REGISTRATION DONE";
                cmdRegister.Visible = false;
                lbl_msg.Text = comm;
                pop_messagebox.ShowOnPageLoad = true;
            }
            else
            {
                throw new Exception("Please Register Course Units first!");
            }
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error! ["+ex.Message+"]";
            pop_messagebox.ShowOnPageLoad = true;
        }
    }
    protected void dsPending_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
    {

    }


    protected void gvCourseRegistration_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        PortalContentTableAdapters.acc_redo_infoTableAdapter RT = new PortalContentTableAdapters.acc_redo_infoTableAdapter();
        if (e.Values["course_status"].ToString() == "Retake")
            RT.DeleteRetakeCourse(Request["reg"].ToString(), e.Values["courseID"].ToString(), int.Parse(Request["sem"]), Request["acadyear"].ToString());

    }

    protected void gvCourseRegistration_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.StartsWith("Exception has been thrown by the target of an invocation."))
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else
        {
            e.ErrorText = UnwrapExceptionMessage(e.Exception);

        }
    }
    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }

    protected void cmdPrintExamPermit_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 900;
        pop_msgbox.Height = 600;
        // Session["Report"] = "Exam Card";
        // Session["acad"] = Request["acadyear"];
        // Session["sem"] = Request["sem"];
        // Session["regno"] = Request["reg"];
        //// Session["prog"] = txtProgramme.Value;
        // Session["typ"] = "EXAM";

        //pop_msgbox.ContentUrl = string.Format("https://eadmin.mru.ac.ug/API/doc_verification.aspx?doc={5}&acadyear={0}&sem={1}&reg={2}&Report={3}&typ={4}"

        pop_msgbox.ContentUrl = string.Format("https://eadmin.mru.ac.ug/API/doc_verification.aspx?doc={5}&acadyear={0}&sem={1}&reg={2}&Report={3}&typ={4}",

           Request["acadyear"],
           Request["sem"],
           Request["reg"],
           "Student Exam Card",
           "EXAMINATION",
           "Student Exam Card");

        // Set Clearance to PRINTED
        StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter CLR = new StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter();

        CLR.fin_ManualClearance("Student Exams", Request["reg"].ToString(), Request["acadyear"].ToString(), int.Parse(Request["sem"].ToString()),
                        Request["reg"].ToString());

        pop_msgbox.ShowOnPageLoad = true;
    }
}