using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using StudentDataTableAdapters;
using ResultsDataTableAdapters;

public partial class UserControls_Results_ResultsUpdates : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_messagebox.HeaderText = SettingsFile.AppName;

    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        
        gvMarksheetInfo.DataBind();
        StatusUpdater();
        pop_messagebox.ContentUrl = "~/COOPERP/Results/AddResultChange.aspx";
        pop_messagebox.Width = 800;
        pop_messagebox.Height = 500;
        pop_messagebox.ShowOnPageLoad = true;

    }

    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {

        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["regno"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_details.ContentUrl = "~/COOPERP/StudentInfo/StudentProfile.aspx";
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();

    }
   

    void StatusUpdater()
    {
       

    }
   
   
    protected void gvMarksheetInfo_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        acad_resultsupdatesTableAdapter UPDATE = new acad_resultsupdatesTableAdapter();
        int new_score = int.Parse(e.NewValues["new_score"].ToString());
        int ID = int.Parse(gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex,"ID").ToString());
        UPDATE.acad_UpdateChangeGrades(ID, new_score, e.OldValues["regno"].ToString());
    }


    protected void cmdApprove_Click1(object sender, EventArgs e)
    {
        acad_resultsupdatesTableAdapter UPDATE = new acad_resultsupdatesTableAdapter();
        string USR = HttpContext.Current.User.Identity.Name,ChangeCreator="-",Comm="No student Selected";
        int noRows = gvMarksheetInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                ChangeCreator = gvMarksheetInfo.GetRowValues(i, "created_by").ToString();
                if (USR == ChangeCreator)
                {
                    Comm = "Sorry, You can not APPROVE your own changes!!";
                }
                else
                {
                    Comm = UPDATE.acad_approveChanges(int.Parse(gvMarksheetInfo.GetRowValues(i,"ID").ToString()),
                        gvMarksheetInfo.GetRowValues(i,"operation").ToString(),gvMarksheetInfo.GetRowValues(i,"regno").ToString(),
                        gvMarksheetInfo.GetRowValues(i,"courseid").ToString().ToString(),HttpContext.Current.User.Identity.Name).ToString();
                }
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }

    protected void cmdReject_Click(object sender, EventArgs e)
    {

    }
}