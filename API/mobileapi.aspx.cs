using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class API_mobileapi : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["act"]=="studdata")
        {
            StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
            DataTable PROFILE = STUD.GetBioData(Request["reg"]);
            Response.Write(jsoncreator.TableToJSON(PROFILE));
        }
        else if (Request["act"] == "LockStatus")
        {
            PortalSecurityTableAdapters.fin_studentlocksTableAdapter LOCK = new PortalSecurityTableAdapters.fin_studentlocksTableAdapter();
            Response.Write(jsoncreator.TableToJSON(LOCK.GetLockStatusData(Request["regno"])));
        }
        else if (Request["act"] == "summarydata")
        {
            MobileDataTableAdapters.mobile_stud_summaryTableAdapter SUMMARY = new MobileDataTableAdapters.mobile_stud_summaryTableAdapter();
            DataTable SUMDATA = SUMMARY.GetData(Request["reg"]);
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "studresults")
        {
            MobileDataTableAdapters.acad_GetAllResultsTableAdapter SUMMARY = new MobileDataTableAdapters.acad_GetAllResultsTableAdapter();
            DataTable SUMDATA = SUMMARY.GetData(Request["reg"]);
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "reghistory")
        {
            MobileDataTableAdapters.acad_registrationTableAdapter REGHISTORY = new MobileDataTableAdapters.acad_registrationTableAdapter();
            DataTable SUMDATA = REGHISTORY.GetRegistrationHistory(Request["reg"]);
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "feesledger")
        {
            MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter LEDGER = new MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter();
            DataTable SUMDATA = LEDGER.GetData(Request["reg"]);
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "directory")
        {
            MobileDataTableAdapters.mobile_GetDirectoryTableAdapter LEDGER = new MobileDataTableAdapters.mobile_GetDirectoryTableAdapter();
            DataTable SUMDATA = LEDGER.GetData(Request["cat"]);
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "availablecourselist")
        {
            StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
            DataTable PROFILE = STUD.GetBioData(Request["reg"]);
            PortalContentTableAdapters.acad_GetPendingCoursesTableAdapter COURSELIST = new PortalContentTableAdapters.acad_GetPendingCoursesTableAdapter();
            /*TimetableDataTableAdapters.acad_teaching_allocationTableAdapter LEDGER = new TimetableDataTableAdapters.acad_teaching_allocationTableAdapter();
            DataTable SUMDATA = LEDGER.GetAllocationsByCourse(PROFILE.Rows[0]["progid"].ToString(), Request["acad"], int.Parse(Request["sem"]),
                int.Parse(Request["yr"]), int.Parse(PROFILE.Rows[0]["entryyear"].ToString()), PROFILE.Rows[0]["intake"].ToString(), PROFILE.Rows[0]["studsesion"].ToString(),
                int.Parse(PROFILE.Rows[0]["studCampus"].ToString()));*/
            DataTable SUMDATA = COURSELIST.GetData(Request["reg"], Request["acad"], int.Parse(Request["sem"]), "Normal");
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "coursereglist")
        {
            MobileDataTableAdapters.acad_course_registrationTableAdapter LEDGER = new MobileDataTableAdapters.acad_course_registrationTableAdapter();
            DataTable SUMDATA = LEDGER.GetStudCourseRegistration(Request["reg"], Request["acad"], int.Parse(Request["sem"]));
            Response.Write(jsoncreator.TableToJSON(SUMDATA));
        }
        else if (Request["act"] == "addcourse")
        {
            try
            {
                StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
                DataTable PROFILE = STUD.GetBioData(Request["reg"]);
                MobileDataTableAdapters.acad_course_registrationTableAdapter COURSE = new MobileDataTableAdapters.acad_course_registrationTableAdapter();
                COURSE.Insert(Request["reg"], Request["courseID"], Request["acad"], uint.Parse(Request["sem"]), Request["stat"],
                    PROFILE.Rows[0]["progid"].ToString(), PROFILE.Rows[0]["studsesion"].ToString());
                Response.Write("Course Added Successfully");
            }
            catch (Exception ex)
            {
                Response.Write("Course addition error! Check for duplicates and try again");
            }

        }
        else if (Request["act"] == "SemesterRegistration")
        {
            try
            {
                PortalContentTableAdapters.acad_StudentRegistrationTableAdapter REG = new PortalContentTableAdapters.acad_StudentRegistrationTableAdapter();
                string regResult = REG.ProcessRegister(Request["reg"], Request["acad"], int.Parse(Request["sem"]), Request["reg"]).ToString();
                // Auto-bill student after registration
                fin_GetStudentFeesTrackListTableAdapter BILLING = new fin_GetStudentFeesTrackListTableAdapter();
                BILLING.fin_Autobilling(Request["reg"], Request["acad"], int.Parse(Request["sem"]), "REG", Request["reg"], "-");
                BILLING.fin_Autobilling(Request["reg"], Request["acad"], int.Parse(Request["sem"]), "ACCOMO", Request["reg"], "-");
                Response.Write(regResult);
            }
            catch (Exception ex)
            {
                Response.Write("Registration Error! [" + ex.Message + "]");
            }
        }
        else if (Request["act"] == "removecourse")
        {
            MobileDataTableAdapters.acad_course_registrationTableAdapter COURSE = new MobileDataTableAdapters.acad_course_registrationTableAdapter();
            COURSE.Delete(uint.Parse(Request["id"]));
            Response.Write("Course Removed Successfully");

        }
        else if (Request["act"] == "enquiry")
        {
            try
            {
                string comms = EmailSenderProtocol.SendEnquiryMail(Request["sender_email"], "Enquiry Received", "Victoria University", "Hullo " + Request["sender_name"] + ", your Enqury has been received. Please await our response.");
                string comm = EmailSenderProtocol.SendEnquiryMail("hammshx@gmail.com", "Student Enquiry", Request["sender_name"], Request["message"] + "\n\nSent by " + Request["sender_name"] + "\n\n" +
                    "Reply Email: " + Request["sender_email"]);
                Response.Write(comm);
            }
            catch (Exception ex) { Response.Write("Error [" + ex.Message + "]"); }
        }
    }
}