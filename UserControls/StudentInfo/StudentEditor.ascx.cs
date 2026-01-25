using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SecurityTableAdapters;

public partial class COOPERP_StudentInfo_StudentEditor : System.Web.UI.UserControl
{
    acad_activity_logTableAdapter sec_log = new acad_activity_logTableAdapter();
    StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (HttpContext.Current.User.IsInRole("Administrator") || HttpContext.Current.User.IsInRole("Academic Registrar") || HttpContext.Current.User.IsInRole("Academic"))
        {
            gvStudentInfo.Columns["Edit"].Visible = true;

        }
        else
            gvStudentInfo.Columns["Edit"].Visible = false;
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {

    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        pop_messagebox.Width = 1200;
        pop_messagebox.Height = 600;
        Session["regno"] = gvStudentInfo.GetRowValues(gvStudentInfo.FocusedRowIndex,"regno");
        pop_messagebox.ContentUrl = "~/COOPERP/StudentInfo/StudentProfile.aspx";
        pop_messagebox.ShowOnPageLoad = true;

    }

   
    protected void cmdExport_Click(object sender, EventArgs e)
    {
        GVE_Students.WriteXlsToResponse("StudentList", new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    protected void CPB_Export_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        GVE_Students.WriteXlsToResponse("StudentList", new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    protected void CBP_Students_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        
    }
    protected void cmdAddNew_Click1(object sender, EventArgs e)
    {
        gvStudentInfo.AddNewRow();
    }
    protected void cmdSpecs_Click(object sender, EventArgs e)
    {
        pop_messagebox.ContentUrl = "~/COOPERP/StudentInfo/SpecialisationManager.aspx";
        pop_messagebox.Width = 600;
        pop_messagebox.Height = 450;
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void gvStudentInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 40;
    }

    protected void gvStudentInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Contains("Exception has been thrown by the target of an invocation.") && e.Exception.InnerException != null)
            e.ErrorText = e.Exception.InnerException.Message;
    }


    protected void AddStudentButton1_Click(object sender, EventArgs e)
    {
        gvStudentInfo.AddNewRow();
        gvStudentInfo.DataBind();
    }

    protected void cmdBillingUpdate_Click(object sender, EventArgs e)
    {
       // txtBillingSystem.Value = STUD.GetStudentCurrentBillingSystem(gvStudentInfo.GetRowValues(i, "regno").ToString());
        pop_billing.ShowOnPageLoad = true;
    }
    protected void cmdApplyBilling_Click(object sender, EventArgs e)
    {
        int noRows = gvStudentInfo.VisibleRowCount, counter = 0;
        
        StudentDataTableAdapters.acad_applicationsTableAdapter applic = new StudentDataTableAdapters.acad_applicationsTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i))
            {
                try
                {
                    STUD.UpdateBillingID(int.Parse(txtBillingSystem.Value.ToString()), gvStudentInfo.GetRowValues(i, "regno").ToString());
                    applic.UpdateApplicantBillingID(int.Parse(txtBillingSystem.Value.ToString()), gvStudentInfo.GetRowValues(i, "regno").ToString());
                    counter++;
                }
                catch (Exception) { }
            }
        }
        gvStudentInfo.DataBind();
        lbl_bill_comment.Text = counter + " Student(s) Set to " + txtBillingSystem.Text;
    }
    protected void gvStudentInfo_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        try
        {
            string ipaddress = GetClientIPAddress();

            // Safe key retrieval
            string student = e.Keys["regno"] != null ? e.Keys["regno"].ToString() : "Unknown";

            // Safe value retrieval with conditional operator
            string old_firstname = e.OldValues["firstname"] != null ? e.OldValues["firstname"].ToString() : "";
            string old_othername = e.OldValues["othername"] != null ? e.OldValues["othername"].ToString() : "";
            string new_firstname = e.NewValues["firstname"] != null ? e.NewValues["firstname"].ToString() : "";
            string new_othername = e.NewValues["othername"] != null ? e.NewValues["othername"].ToString() : "";

            string oldname = old_firstname + " " + old_othername;
            string newname = new_firstname + " " + new_othername;

            string old_dateofbirth = e.OldValues["dob"] != null ? e.OldValues["dob"].ToString() : "";
            string new_dateofbirth = e.NewValues["dob"] != null ? e.NewValues["dob"].ToString() : "";

            string old_gender = e.OldValues["gender"] != null ? e.OldValues["gender"].ToString() : "";
            string new_gender = e.NewValues["gender"] != null ? e.NewValues["gender"].ToString() : "";

            string old_nationality = e.OldValues["nationality"] != null ? e.OldValues["nationality"].ToString() : "";
            string new_nationality = e.NewValues["nationality"] != null ? e.NewValues["nationality"].ToString() : "";

            string old_entryno = e.OldValues["entryno"] != null ? e.OldValues["entryno"].ToString() : "";
            string new_entryno = e.NewValues["entryno"] != null ? e.NewValues["entryno"].ToString() : "";

            string old_studsesion = e.OldValues["studsesion"] != null ? e.OldValues["studsesion"].ToString() : "";
            string new_studsesion = e.NewValues["studsesion"] != null ? e.NewValues["studsesion"].ToString() : "";

            string old_intake = e.OldValues["intake"] != null ? e.OldValues["intake"].ToString() : "";
            string new_intake = e.NewValues["intake"] != null ? e.NewValues["intake"].ToString() : "";

            string old_gradSystemID = e.OldValues["gradSystemID"] != null ? e.OldValues["gradSystemID"].ToString() : "";
            string new_gradSystemID = e.NewValues["gradSystemID"] != null ? e.NewValues["gradSystemID"].ToString() : "";

            string old_studCampus = e.OldValues["studCampus"] != null ? e.OldValues["studCampus"].ToString() : "";
            string new_studCampus = e.NewValues["studCampus"] != null ? e.NewValues["studCampus"].ToString() : "";

            string old_entryyear = e.OldValues["entryyear"] != null ? e.OldValues["entryyear"].ToString() : "";
            string new_entryyear = e.NewValues["entryyear"] != null ? e.NewValues["entryyear"].ToString() : "";


            if (oldname != newname && !string.IsNullOrEmpty(newname))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Name: " + oldname + " New Name: " + newname + " IP Adress: " + ipaddress, "Changed Student Name", DateTime.Now);

            if (old_dateofbirth != new_dateofbirth && !string.IsNullOrEmpty(new_dateofbirth))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Birth Date: " + old_dateofbirth + " New BirthDate: " + new_dateofbirth + " IP Adress: " + ipaddress, "Changed Student Birth Date", DateTime.Now);

            if (old_gender != new_gender && !string.IsNullOrEmpty(new_gender))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Gender: " + old_gender + " New Gender: " + new_gender + " IP Adress: " + ipaddress, "Changed Student Gender", DateTime.Now);

            if (old_nationality != new_nationality && !string.IsNullOrEmpty(new_nationality))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Nationality: " + old_nationality + " New Nationality: " + new_nationality + " IP Adress: " + ipaddress, "Changed Student Nationality", DateTime.Now);

            if (old_entryno != new_entryno && !string.IsNullOrEmpty(new_entryno))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old RegNo: " + old_entryno + " New RegNo: " + new_entryno + " IP Adress: " + ipaddress, "Changed Student Reg No", DateTime.Now);

            if (old_studsesion != new_studsesion && !string.IsNullOrEmpty(new_studsesion))
            {
                //sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Session: " + old_studsesion + " New Session: " + new_studsesion + " IP Adress: " + ipaddress, "Changed Student Study Session", DateTime.Now);
                //STUD.UpdateStudentRegno(student);
            }

            if (old_intake != new_intake && !string.IsNullOrEmpty(new_intake))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Intake: " + old_intake + " New Intake: " + new_intake + " IP Adress: " + ipaddress, "Changed Student Intake", DateTime.Now);

            if (old_gradSystemID != new_gradSystemID && !string.IsNullOrEmpty(new_gradSystemID))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Grading System: " + old_gradSystemID + " New Grading System: " + new_gradSystemID + " IP Adress: " + ipaddress, "Changed Student Grading System", DateTime.Now);

            if (old_studCampus != new_studCampus && !string.IsNullOrEmpty(new_studCampus))
            {
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Campus: " + old_studCampus + " New Campus: " + new_studCampus + " IP Adress: " + ipaddress, "Changed Student Campus", DateTime.Now);
               // STUD.UpdateStudentRegno(student);
            }

            if (old_entryyear != new_entryyear && !string.IsNullOrEmpty(new_entryyear))
                sec_log.Insert(HttpContext.Current.User.Identity.Name, "Student Data Editor", "Student No. " + student + " Old Entry Year: " + old_entryyear + " New Entry Year: " + new_entryyear + " IP Adress: " + ipaddress, "Changed Student Entry Year", DateTime.Now);
        }
        catch (Exception ex)
        {
            // Log the actual error
            sec_log.Insert("SYSTEM", "Error", "Error in gvStudentInfo_RowUpdated: " + ex.Message, "Error", DateTime.Now);
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