using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_scholarshipsmanagement : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
            txtScholarships.SelectedIndex = 0;
        }

        Session["ReportType"] = "ScholarshipList";
        Session["sid"] = txtScholarships.Value;
        Session["year"] = txtAcadYear.Text;
        Session["term"] = txtTerm.Text;

    }

    protected void Page_PreInit(object sender, EventArgs e)
    {
        
    }
    protected void txtAccountSearch_TextChanged(object sender, EventArgs e)
    {
        txtRegNo.DataBind();
    }
    protected void txtClass_NumberChanged(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        StudentAccountingDataTableAdapters.scholarshipstudentsTableAdapter stud = new StudentAccountingDataTableAdapters.scholarshipstudentsTableAdapter();
        try
        {
            
            stud.Insert(txtRegNo.Value.ToString(), uint.Parse(txtScholarships.Value.ToString()), uint.Parse(txtTerm.Text), txtAcadYear.Text, 0);
            lbl_msgbox.Text = "Student Added Successfully";
            gvStudents.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msgbox.Text = string.Format("Error! {0}", ex.Message);
        }
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_scholarships.Width = 800;
        pop_scholarships.Height = 600;
        pop_scholarships.ContentUrl = "~/COOPERP/financials/Reports/Default.aspx";
        Session["sid"] = txtScholarships.Value;
        Session["year"] = txtAcadYear.Text;
        Session["term"] = txtTerm.Text;
        Session["ReportType"] = "ScholarshipList";
        pop_scholarships.ShowOnPageLoad = true;
    }
    protected void cmdScholarships_Click(object sender, EventArgs e)
    {

    }
    protected void gvStudents_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}