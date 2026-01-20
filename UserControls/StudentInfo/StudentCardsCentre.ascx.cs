using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_StudentCardsCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultGraduationYr();

            txtYear.DataSource = SettingsFile.ReturnYears();
            txtYear.DataBind();
            txtYear.Text=(DateTime.Today.AddYears(1).Year.ToString());

            txtMonth.DataSource = SettingsFile.ReturnMonths();
            txtMonth.DataBind();
            txtMonth.SelectedIndex = 0; ;


        }
        cmdPrintList.Text = "Print "+txtDocumentType.Text;
    }
    protected void cmdPrintList_Click(object sender, EventArgs e)
    {
        Session["Report"] = txtCartType.Text;
        Session["fax"] = txtFaculty.Value;
        Session["prog"] = txtProgramme.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sem"] = txtSemester.Text;
        Session["intk"] = txtIntake.Text;
        Session["reg"] = "-";
        pop_details.Width = 600;
        pop_details.Height = 400;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        pop_details.ShowOnPageLoad = true;

    }
    protected void cmdChangeStatus_Click(object sender, EventArgs e)
    {
        int noRows = gvStudentInfo.VisibleRowCount,ID,counter=0;
        string comm = "No Registered Student Selected";
        StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter CARDS = new StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter();
        for(int i=0;i<noRows;i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i) /*&& gvStudentInfo.GetRowValues(i, "reg_status").ToString() != "UNREGISTERED"*/)
            {
                ID = int.Parse(gvStudentInfo.GetRowValues(i, "ID").ToString());
                CARDS.UpdateCardStatus(ID);
                counter++;
                comm=counter+" Student Status Updated";
            }
        }
        gvStudentInfo.DataBind();
        lbl_comment.Text =comm;
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void imgProfile_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["regno"] = gvStudentInfo.GetRowValues(gvStudentInfo.FocusedRowIndex, "reg_no");
        pop_details.ContentUrl = "~/COOPERP/StudentInfo/StudentProfile.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void txtFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtProgramme.DataBind();
       // txtProgramme.SelectedIndex = 0;
    }
    protected void cmdCreateList_Click(object sender, EventArgs e)
    {
        StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter CARDS = new StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter();
        CARDS.acad_CreateCardList(txtFaculty.Value.ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), txtCartType.Text, txtIntake.Text, HttpContext.Current.User.Identity.Name);
        gvStudentInfo.DataBind();
        lbl_comment.Text = "List Refreshed Successfully";
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void gvStudentInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
    protected void cmdSetExpiry_Click(object sender, EventArgs e)
    {
        pop_expdate.ShowOnPageLoad = true;
    }
    protected void cmdSetExp_Click(object sender, EventArgs e)
    {
        int noRows = gvStudentInfo.VisibleRowCount, ID, counter = 0;
        lbl_set_date_comm.Text = "";
        string comm = "No Registered Student Selected";
        StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter CARDS = new StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i) /*&& gvStudentInfo.GetRowValues(i, "reg_status").ToString() != "UNREGISTERED"*/)
            {
                ID = int.Parse(gvStudentInfo.GetRowValues(i, "ID").ToString());
                CARDS.SetExpiry(txtMonth.Text+" "+txtYear.Text,ID);
                counter++;
                comm = counter + "Cards Processed";
            }
        }
        gvStudentInfo.DataBind();
        lbl_set_date_comm.Text = comm;
    }
}