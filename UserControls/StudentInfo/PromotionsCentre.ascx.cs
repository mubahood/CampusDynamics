using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_PromotionsCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();

            txtentryyear.DataSource = SettingsFile.ReturnYears();
            txtentryyear.DataBind();
            txtentryyear.Text = DateTime.Now.Year.ToString();

            txtNewAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtNewAcadYear.DataBind();
            txtNewAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();

            txtIntake.DataSource = SettingsFile.ReturnMonths();
            txtIntake.DataBind();
            txtIntake.SelectedIndex = 0;


        }
    }
    protected void cmdCreateList_Click(object sender, EventArgs e)
    {
        PromotionDataTableAdapters.acad_registrationTableAdapter REG = new PromotionDataTableAdapters.acad_registrationTableAdapter();
        int noRows = gvStudentInfo.VisibleRowCount;
        uint curr_year=uint.Parse(txtAcadYear.Text.Substring(0,4)),counter=0;
        
        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i) && gvStudentInfo.GetRowValues(i, "stat").ToString()=="CONTINUING")
            {
                try
                {
                    uint studyr = uint.Parse(gvStudentInfo.GetRowValues(i, "studyyear").ToString());
                    if (txtChangeYear.Checked) { studyr = studyr + 1; }
                    string reg = gvStudentInfo.GetRowValues(i, "regno").ToString();
                    REG.Insert(reg, txtNewAcadYear.Text, uint.Parse(txtNewSemester.Text), "UNREGISTERED", studyr, "UNPRINTED", gvStudentInfo.GetRowValues(i, "residence_status").ToString(), "UNPRINTED",
                        "UNCLEARED", null, "-", "-");
                    counter++;
                }
                catch (Exception) { }
            }

        }

        lbl_comment.Text = counter+" Students Processed";
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void cmdChangeStatus_Click(object sender, EventArgs e)
    {

    }
    protected void gvStudentInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }

    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        PromotionDataTableAdapters.acad_registrationTableAdapter REG = new PromotionDataTableAdapters.acad_registrationTableAdapter();
        int noRows = gvStudentInfo.VisibleRowCount;
        uint curr_year = uint.Parse(txtAcadYear.Text.Substring(0, 4)), counter = 0;

        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentInfo.Selection.IsRowSelected(i))
            {
                try
                {
                    uint ID = uint.Parse(gvStudentInfo.GetRowValues(i, "ID").ToString());
                   
                    REG.Delete(ID);
                    counter++;
                }
                catch (Exception) { }
            }

        }

        lbl_comment.Text = counter + " Students Deleted";
        pop_messagebox.ShowOnPageLoad = true;
    }

    
}