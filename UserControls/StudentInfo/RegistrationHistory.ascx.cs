using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_RegistrationHistory : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        gvRegistrationHistory.AddNewRow();

    }
    protected void gvRegistrationHistory_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["regno"] = Session["regno"];
        e.NewValues["acad_year"] = SettingsFile.ReturnDefaultAcademicYr();
    }
    protected void gvRegistrationHistory_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        StudentAccountingDataTableAdapters.fin_GetStudentLedgerTableAdapter CLEARANCE = new StudentAccountingDataTableAdapters.fin_GetStudentLedgerTableAdapter();
        try
        {
            string newRegValues, oldValues;
            newRegValues = e.NewValues["regstatus"].ToString();
            oldValues = e.OldValues["regstatus"].ToString();
            e.NewValues["registeredBy"] = Session["username"];
            /*Exception ex = new Exception("Sorry. Registration requires 60% fees payment.");
            if ((newRegValues == "REGISTERED" || newRegValues == "LATE REGISTERED") && oldValues == "UNREGISTERED" && CLEARANCE.fin_CheckClearance("REG", e.OldValues["regno"].ToString(), e.OldValues["acad_year"].ToString(),
                int.Parse(e.NewValues["semester"].ToString()),int.Parse(e.NewValues["studyyear"].ToString())).ToString()!="CLEARED")
            {
                e.NewValues["regstatus"] = e.OldValues["regstatus"];
                
                throw ex;
                
            }
            else
            {*/
            lbl_comment.Text = "Registration Update Completed";
            //}
        }
        catch (Exception ex)
        {
            lbl_comment.Text = ex.Message;

        }
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void gvRegistrationHistory_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = txtDocType.Value;
        Session["fax"] = "-";
        Session["prog"] = "-";
        Session["acad"] = gvRegistrationHistory.GetRowValues(gvRegistrationHistory.FocusedRowIndex, "acad_year");
        Session["sem"] = gvRegistrationHistory.GetRowValues(gvRegistrationHistory.FocusedRowIndex, "semester");
        Session["intk"] = "-";
        Session["reg"] = Session["regno"];
        Session["rid"] = gvRegistrationHistory.GetRowValues(gvRegistrationHistory.FocusedRowIndex, "ID");
        Response.Redirect("~/COOPERP/XtraReports/Default.aspx");
    }
    protected void gvRegistrationHistory_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void gvRegistrationHistory_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        //ID, regno, acad_year, semester, regstatus, studyyear, id_cardStatus, residence_status, reg_CardStatus, examClearance, examClearanceDate, clearedBy, registeredBy
        e.NewValues["id_cardStatus"] = "UNPRINTED";
        e.NewValues["residence_status"] = "NON RESIDENT";
        e.NewValues["reg_CardStatus"] = "UNPRINTED";
        e.NewValues["examClearance"] = "UNCLEARED";
        e.NewValues["clearedBy"] = "-";
        e.NewValues["registeredBy"] = HttpContext.Current.User.Identity.Name;

    }



    protected void cmdClearExam_Click(object sender, EventArgs e)
    {
        int noRows = gvRegistrationHistory.VisibleRowCount, counter = 0;
        string comm = "No Students Selected";
        StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter CLR = new StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter();
        if (HttpContext.Current.User.IsInRole("Bursar"))
        {
            for (int i = 0; i < noRows; i++)
            {
                if (gvRegistrationHistory.Selection.IsRowSelected(i))
                {
                    string acad = gvRegistrationHistory.GetRowValues(i, "acad_year").ToString();
                    string sem = gvRegistrationHistory.GetRowValues(i, "semester").ToString();
                    string clearance = gvRegistrationHistory.GetRowValues(i, "examClearance").ToString();
                    if (clearance == "UNCLEARED")
                    {
                        CLR.fin_ManualClearance(txtClearanceType.Value.ToString(), Session["regno"].ToString(), acad, int.Parse(sem),
                            HttpContext.Current.User.Identity.Name);
                    }
                    else
                    {
                        CLR.fin_RevokeClearance(txtClearanceType.Value.ToString(), Session["regno"].ToString(), acad, int.Parse(sem),
                        HttpContext.Current.User.Identity.Name);
                    }
                    counter++;
                    comm = counter + " Semesters(s) " + txtClearanceType.Value + " Processed";

                }
            }
        }
        else
        {
            comm = "Sorry. Only Bursar Handles Manual Clearances!";
        }
        gvRegistrationHistory.DataBind();
        lbl_comment.Text = comm;
        pop_messagebox.ContentUrl = "";
        pop_messagebox.ShowOnPageLoad = true;
    }
}