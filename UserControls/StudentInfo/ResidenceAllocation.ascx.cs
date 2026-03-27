using StudentAccountingDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_ResidenceAllocation : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultGraduationYr();
        }

    }
    protected void txtFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {


    }
    protected void cmdCreateList_Click(object sender, EventArgs e)
    {
        ReidenceDataTableAdapters.acad_residenceTableAdapter RES = new ReidenceDataTableAdapters.acad_residenceTableAdapter();
        RES.acad_CreateResidenceList(txtAcadYear.Text, int.Parse(txtSemester.Text));
        gvStudentInfo.DataBind();
        lbl_comment.Text = "Residence List Refreshed";
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void cmdPrintList_Click(object sender, EventArgs e)
    {

    }
    protected void gvStudentInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdNonResidence_Click(object sender, EventArgs e)
    {
        pop_hall_info.Height = 500;
        pop_hall_info.ShowOnPageLoad = true;
    }
    protected void gvHallInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdAllocateHall_Click(object sender, EventArgs e)
    {
        pop_assignHall.ShowOnPageLoad = true;
    }
    protected void cmdSetResidence_Click(object sender, EventArgs e)
    {
        ReidenceDataTableAdapters.acad_residenceTableAdapter RES = new ReidenceDataTableAdapters.acad_residenceTableAdapter();
        int noRows = gvStudentInfo.VisibleRowCount, counter = 0;
        string regno = "-", Comm = "Billing Not Completed", residence;
        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i))
            {
                RES.acad_UpdateResidence(gvStudentInfo.GetRowValues(i, "regno").ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text), int.Parse(txtNewHall.Value.ToString()));
                
                fin_GetStudentFeesTrackListTableAdapter STUD = new fin_GetStudentFeesTrackListTableAdapter();

                        try
                        {
                            regno = gvStudentInfo.GetRowValues(i, "regno").ToString();
                            residence = txtNewHall.Text;
                            if (residence != "Non-Resident")
                            {
                                STUD.fin_Autobilling(regno, txtAcadYear.Text, int.Parse(txtSemester.Text), "ACCOMO", HttpContext.Current.User.Identity.Name, "-");
                            }
                            counter++;
                        }
                        catch (Exception ex)
                        {
                            // MySQL error 1062 = duplicate key — student already
                            // billed for accommodation. Safe to skip and continue.
                            var mex = ex as MySql.Data.MySqlClient.MySqlException;
                            if (mex == null && ex.InnerException != null)
                                mex = ex.InnerException as MySql.Data.MySqlClient.MySqlException;
                            if (mex != null && mex.Number == 1062)
                            {
                                counter++;
                                continue;
                            }
                            lbl_set_hall_comm.Text = "Error! " + ex.Message + " On Reg No: " + regno;
                            break;
                        }
                    
                
                
            }
        }
        gvStudentInfo.DataBind();
        lbl_set_hall_comm.Text =counter+" Allocations Completed";
    }
}