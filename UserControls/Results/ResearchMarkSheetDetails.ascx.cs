using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_WebUserControl : System.Web.UI.UserControl
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
        int noRows = gvResearchResultsList.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvResearchResultsList.Selection.IsRowSelected(i))
            {
                
                ResultsBLL RES = new ResultsBLL();
                try
                {
                    lbl_comment.Text = RES.CaptureResults(gvResearchResultsList.GetRowValues(i, "reg_no").ToString(),
                        Session["csid"].ToString(), Session["acad"].ToString(), int.Parse(Session["sem"].ToString()),
                        int.Parse(gvResearchResultsList.GetRowValues(i, "final_score").ToString()),
                        int.Parse(Session["cyr"].ToString()), gvResearchResultsList.GetRowValues(i, "stat").ToString(),
                        int.Parse(gvResearchResultsList.GetRowValues(i, "ID").ToString()), txtAltCourseID.Text,0,0,"Normal");

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
        gvResearchResultsList.DataBind();
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
        try
        {
            ResultsDataTableAdapters.acad_researchexamsettingsTableAdapter EX = new ResultsDataTableAdapters.acad_researchexamsettingsTableAdapter();
            EX.ApproveResults(txtNewStatus.Value.ToString(), int.Parse(Session["mid"].ToString()));

            pop_messagebox.ShowOnPageLoad = false;
        }
        catch (Exception ex)
        {
            lbl_comment0.Text = "Error! " + ex.Message;
        }
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