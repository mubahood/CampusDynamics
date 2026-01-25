using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using StudentDataTableAdapters;

public partial class UserControls_StudentInfo_StudentSpecialisationCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
        txtAcadYear.DataBind();
        if (!IsPostBack)
        {
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }

    }
    protected void cmdSet_Specialisation_Click(object sender, EventArgs e)
    {
        try
        {
            acad_studentTableAdapter STU = new acad_studentTableAdapter();
            int noRows = gvStudentInfo.VisibleRowCount;
            uint counter = 0;
        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i))
            {
                try
                {
                   string reg = gvStudentInfo.GetRowValues(i, "regno").ToString();
                   STU.UpdateSpecialisation(txt_newspecialisation.Value.ToString(),reg);
                    counter++;
                }
                catch (Exception ex) {
                    
                }
            }

        }
            
       lbl_response.Text = counter+" Students Processed";
        pop_details.ShowOnPageLoad=true;
            }
                catch (Exception ex) {
                    lbl_response.Text = "Error: " + UnwrapExceptionMessage(ex);
                    pop_details.ShowOnPageLoad=true;
                }
    }


    protected void btn_managespecialisations_Click(object sender, EventArgs e)
    {
        pop_specialisations.HeaderText = txtProgramme.Text + " SPECIALISATIONS";
    }

    protected void gvStudentInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void btn_addspecialisation_Click(object sender, EventArgs e)
    {
        gv_Specialisations.AddNewRow();
    }
    protected void gv_Specialisations_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        e.NewValues["prog_id"] = txtProgramme.Value.ToString();
    }

    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }
    protected void gv_Specialisations_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = UnwrapExceptionMessage(e.Exception);
    }
    protected void gv_Specialisations_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["prog_id"] = txtProgramme.Value.ToString();
    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        Session["prog"] = txtProgramme.Value;
    }
    protected void gv_Specialisations_RowInserted(object sender, DevExpress.Web.Data.ASPxDataInsertedEventArgs e)
    {
        txt_newspecialisation.DataBind();
        txt_currentspecialisation.DataBind();
    }
}