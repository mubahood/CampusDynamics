using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_MarksheetDetails : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_DetailsMsg.Width = 300;
        rp_details.HeaderText = Session["headerText"].ToString();
        if (Session["status"].ToString() == "APPROVED")
        {
            cmdApprove.Enabled = true;
        }
        else
        {
            cmdApprove.Enabled = false;
        }

        if (Session["Exam_format"].ToString() == "With Practicals")
            gvMarksheet.Columns["practicals"].Visible = true;
        else
            gvMarksheet.Columns["practicals"].Visible = false;

        pop_messagebox.HeaderText = SettingsFile.AppName;
    }
    //protected void cmdApprove_Click(object sender, EventArgs e)
    //{
    //    pop_DetailsMsg.Width = 300;
    //    lbl_comment.Text = "This is Hot";
    //}



    protected void ApproveResults()
    {
        pop_DetailsMsg.Width = 300;
       
        String comm = "No Results Selected";
        int noRows = gvMarksheet.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheet.Selection.IsRowSelected(i))
            {
                //string csid,string acad,int sem, int mark,int cyr ,string stat,int rid
                //ID, reg_no, settingID, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, exam_total, course_work, final_score, stat, attempt
                ResultsBLL RES = new ResultsBLL();
                try
                {
                    lbl_comment.Text = RES.CaptureResults(gvMarksheet.GetRowValues(i, "reg_no").ToString(),
                        Session["csid"].ToString(), Session["acad"].ToString(), int.Parse(Session["sem"].ToString()),
                        int.Parse(gvMarksheet.GetRowValues(i, "final_score").ToString()),
                        int.Parse(Session["cyr"].ToString()), gvMarksheet.GetRowValues(i, "stat").ToString(),
                        int.Parse(gvMarksheet.GetRowValues(i, "ID").ToString()),txtAltCourseID.Text,Convert.ToDouble(Session["practical_percent"].ToString()),
                        Convert.ToDouble(gvMarksheet.GetRowValues(i, "practicals").ToString()),Session["Exam_format"].ToString());

                    if (comm.Contains("Error"))
                    {
                        break;
                    }

                }
                catch (Exception ex) 
                { 
                    comm = "Error!" + ex.Message;
                    lbl_comment.Text = comm;
                }
            }
            
        }
       
        
    }
    protected void cmdApprove_Click1(object sender, EventArgs e)
    {
        try
        {
            ApproveResults();
        }
        catch (Exception ex)
        {
            string comm = "Error!" + ex.Message;
            lbl_comment.Text = comm;
        }
        gvMarksheet.DataBind();
        pop_DetailsMsg.ShowOnPageLoad = true;

    }

    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        lbl_courseInfo.Text = string.Format("STATUS UPDATE FOR \n{1} [{0}]", Session["csid"].ToString(),
            Session["CourseName"].ToString());
       
        StatusUpdater();
        pop_messagebox.ShowOnPageLoad = true;

    }

    protected void cmdStatusChange_Click(object sender, EventArgs e)
    {
        ResultsDataTableAdapters.acad_examsettingsTableAdapter EX = new ResultsDataTableAdapters.acad_examsettingsTableAdapter();
        EX.ApproveResults(txtNewStatus.Value.ToString(), int.Parse(Session["mid"].ToString()));
        
        pop_messagebox.ShowOnPageLoad = false;
    }

    void StatusUpdater()
    {
        if (Session["status"].ToString() == "SUBMITTED")
        {
            txtNewStatus.Text = "APPROVED";
        }
        else if (Session["status"].ToString() == "APPROVED")
        {
            txtNewStatus.Text = "CAPTURED";
        }
        else if (Session["status"].ToString() == "CAPTURED")
        {
            txtNewStatus.Value = "NEW";
        }
        else if (Session["status"].ToString() == "NEW")
        {
            txtNewStatus.Value = "SUBMITTED";
        }

    }
}