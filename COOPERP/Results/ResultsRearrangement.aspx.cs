using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ResultsDataTableAdapters;

public partial class COOPERP_Results_Reports_ResultsRearrangement : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        rp_results.HeaderText = "RESULTS ALIGNMENT ..:: " + Session["stud_name"] + "[" + Session["reg"]+"]";
    }
    protected void gvResultsInfo_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        acad_GetSemesterResultsTableAdapter RES = new acad_GetSemesterResultsTableAdapter();

        //RES.UpdateCourseCode(e.OldValues["ID"].ToString(), e.NewValues["courseid"].ToString());

        RES.acad_ResultsUpdatesLog(Session["reg"].ToString(),HttpContext.Current.User.Identity.Name);
        
    }
    protected void cmdChangeRegNo_Click(object sender, EventArgs e)
    {
        if (txtNewRegNo.Text == "")
        {
            lbl_msg.Text = "Enter the new Code Please";
        }
        else
        {
            try
            {
                StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
                STUD.acad_RegNoChange(Session["reg"].ToString(), txtNewRegNo.Text);
                lbl_msg.Text = "Number Changed from \n" + Session["reg"].ToString() + " \nto\n " + txtNewRegNo.Text;

            }
            catch (Exception ex)
            {
                lbl_msg.Text = "Error! " + ex.Message;

            }
        }
        pop_msgBox.ShowOnPageLoad = true;

    }
    protected void cmdChangeCode_Click(object sender, EventArgs e)
    {
        String reg = "-",OldCode="-";
        if (txtNewCode.Text == "")
        {
            lbl_msg.Text = "Enter the new Code Please";
        }
        else
        {
            ResultsDataTableAdapters.acad_resultsupdatesTableAdapter RES = new acad_resultsupdatesTableAdapter();
            for (int i = 0; i < gvResultsInfo.VisibleRowCount; i++)
            {
                if (gvResultsInfo.Selection.IsRowSelected(i))
                {
                    reg = Session["reg"].ToString();
                    OldCode = gvResultsInfo.GetRowValues(i, "courseid").ToString();
                    RES.acad_ChangeCodes(reg, OldCode, txtNewCode.Text, HttpContext.Current.User.Identity.Name);
                    lbl_msg.Text = "Code change Completed";
                }
            }
            gvResultsInfo.DataBind();
        }
        pop_msgBox.ShowOnPageLoad = true;
    }
    protected void cmdAddBridgeCS_Click(object sender, EventArgs e)
    {
        if (CV_BridgeInfo.VisibleCardCount == 0)
        {
            acad_bridgequalificationTableAdapter BC = new acad_bridgequalificationTableAdapter();
            BC.Insert(Session["reg"].ToString(), "-", "-", "-", "-","-","-");
            CV_BridgeInfo.DataBind();
            lbl_msgBridge.Text = "Blank Qualification Added. Edit and Save Changes";
        }
        else
        {
            lbl_msgBridge.Text = "Caution. Only ONE qualification can be Added";
        }
        pop_msgBoxBridge.ShowOnPageLoad = true;
    }
    protected void cmdSyncYear_Click(object sender, EventArgs e)
    {
        SyncManager("Batch");

    }
    protected void gvResultsInfo_RowDeleted(object sender, DevExpress.Web.Data.ASPxDataDeletedEventArgs e)
    {
       
    }
    protected void gvResultsInfo_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        acad_GetSemesterResultsTableAdapter DELRES = new acad_GetSemesterResultsTableAdapter();
        DELRES.acad_DeletePaperLog(int.Parse(e.Values["ID"].ToString()), HttpContext.Current.User.Identity.Name);
    }
    protected void cmdSyncSingle_Click(object sender, EventArgs e)
    {
        SyncManager("Single");
    }
    void SyncManager(String Typ)
    {
        acad_resultsupdatesTableAdapter SYNC = new acad_resultsupdatesTableAdapter();
        for (int i = 0; i < gvResultsInfo.VisibleRowCount; i++)
        {
            if (gvResultsInfo.Selection.IsRowSelected(i))
            {
                SYNC.acad_SyncYearSem(Session["reg"].ToString(), gvResultsInfo.GetRowValues(i, "courseid").ToString(), gvResultsInfo.GetRowValues(i, "acad").ToString(),
                    int.Parse(gvResultsInfo.GetRowValues(i, "studyyear").ToString()), int.Parse(gvResultsInfo.GetRowValues(i, "semester").ToString()),
                    HttpContext.Current.User.Identity.Name,Typ);
                lbl_msg.Text = "Sychronisation Complete";
            }
        }
        pop_msgBox.ShowOnPageLoad = true;
    }
    protected void gvResultsInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.Exception != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
    }

    protected void gvResultsInfo_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 30;
    }
}