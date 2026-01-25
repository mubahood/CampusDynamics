using ResultsDataTableAdapters;
using StudentDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Results_AddResultChange : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
        txtAcadYear.DataBind();
        txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
     
        Labels();
    }
    protected void txtRegNo_TextChanged(object sender, EventArgs e)
    {
        Labels();
    }
    protected void cmdStatusChange_Click(object sender, EventArgs e)
    {
        acad_resultsupdatesTableAdapter UPDATE = new acad_resultsupdatesTableAdapter();
        lbl_comment.Text = UPDATE.acad_NewChange(txtRegNo.Text, txtCourseCode.Value.ToString(), txtOperation.Text, int.Parse(txtSemester.Text),
            int.Parse(txtStudyYear.Text), txtAcadYear.Text, HttpContext.Current.User.Identity.Name).ToString();
       
    }
   
    void Labels()
    {
        try
        {
            acad_studentTableAdapter STUD = new acad_studentTableAdapter();
            string nm = STUD.GetNameByRegNo(txtRegNo.Text).ToString();
            if (nm == null)
            {
                nm = "ENTER CORRECT REG. NUMBER";
                cmdAddPaper.Enabled = false;

            }
            else
            {
                nm = string.Format("RESULTS CHANGES FOR \n[{0}]", nm);
                cmdAddPaper.Enabled = true;
            }
            lbl_courseInfo.Text = nm;
        }
        catch (Exception) { }

    }
}