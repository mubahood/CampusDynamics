using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ResultsDataTableAdapters;

public partial class COOPERP_Results_ResultsApprovals : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
            pop_details.HeaderText = SettingsFile.AppName;
        }
    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        try
        {
            String Comm = "No Programme Selected!";
            if (HttpContext.Current.User.IsInRole("Academic Registrar"))
            {
                int noRows = gvMarksheetInfo.VisibleRowCount, Counter = 0;
                acad_results_securitylevelTableAdapter rel = new acad_results_securitylevelTableAdapter();
                for (int i = 0; i < noRows; i++)
                {
                    if (gvMarksheetInfo.Selection.IsRowSelected(i))
                    {
                        rel.UpdateSecurityLevel(long.Parse(gvMarksheetInfo.GetRowValues(i, "ID").ToString()));
                        Counter++;
                    }

                }
                if (Counter > 0)
                {
                    if (Counter == 1)
                        Comm = Counter + " Programme\'s Status Updated";
                    else
                        Comm = Counter + " Programmes\' Status Updated";
                }
            }
            else
            {
                Comm = "Sorry!, Only the Academic Registrar can Perform this action";
            }

            lbl_comment.Text = Comm;
        }
        catch (Exception ex)
        {
            lbl_comment.Text = "Ërror! " + ex.Message;
        }
        pop_details.Height = 100;
        pop_details.Width = 300;
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdUpdateSessions_Click(object sender, EventArgs e)
    {
        int selectedprogrammes = gvMarksheetInfo.Selection.Count;

        if (selectedprogrammes == 0)
        {

            lbl_comment.Text = "Please Select Programmes to Update Study Session";
            pop_details.ShowOnPageLoad = true;
        }
        else
        {
            txtSessions.Text = null;
            lbl_session_comment.Text = " ";
            pop_sessionEditor.ShowOnPageLoad = true;
        }
    }
    protected void cmdEditSessions_Click(object sender, EventArgs e)
    {
        int noRows = gvMarksheetInfo.VisibleRowCount, counter1 = 0;
        acad_results_securitylevelTableAdapter sess = new acad_results_securitylevelTableAdapter();
        if (!string.IsNullOrEmpty(txtSessions.Text))
        {
            for (int i = 0; i < noRows; i++)
            {
                if (gvMarksheetInfo.Selection.IsRowSelected(i))
                {
                    try
                    {
                        sess.UpdateResultsStudySession(txtSessions.Value.ToString(),long.Parse(gvMarksheetInfo.GetRowValues(i, "ID").ToString()));
                        counter1++;
                    }
                    catch (Exception ex)
                    {
                        lbl_session_comment.ForeColor = System.Drawing.Color.Red;
                        lbl_session_comment.Text = "Error: " + ex.Message;
                    }
                }
            }
            gvMarksheetInfo.DataBind();

            if (counter1 == 0)
            {
                lbl_session_comment.ForeColor = System.Drawing.Color.Red;
                lbl_session_comment.Text = "Error: Programmes are not Selected OR Possible Duplicate.";
            }

            else
            {
                lbl_session_comment.ForeColor = System.Drawing.Color.Blue;
                lbl_session_comment.Text = counter1 + " Programme(s) Updated to " + txtSessions.Text;
            }
        }
        else
        {
            lbl_session_comment.ForeColor = System.Drawing.Color.Red;
            lbl_session_comment.Text = "Please Select the Study Session to Update Programmes.";
        }
    }
}