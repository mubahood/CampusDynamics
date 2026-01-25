using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExamSettingTableAdapters;

public partial class COOPERP_Timetables_ExamPaperDetail : System.Web.UI.Page
{
    acad_examination_papers_approvalcommentsTableAdapter com = new acad_examination_papers_approvalcommentsTableAdapter();

    protected void Page_Load(object sender, EventArgs e)
    {
        rp_details.HeaderText = Session["headerText"].ToString();
        if (Session["status"].ToString() != "SUBMITTED" || !HttpContext.Current.User.IsInRole("Dean"))
        {
            gvExam.Columns["Edit"].Visible = false;
            
            cmdprint.Enabled = false;
        }
        if (!HttpContext.Current.User.IsInRole("Dean"))
        {
            cmdComment.Enabled = false;
        }
        else
            if (Session["status"].ToString() == "FOR REVIEW")
            {
                cmdComment.Enabled = true;
            }
            else
                if (Session["status"].ToString() != "SUBMITTED")
                    cmdComment.Enabled = false;
    }
    protected void gvExam_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        //if (HttpContext.Current.User.IsInRole("Dean"))
        //{
            e.NewValues["approved_by"] = HttpContext.Current.User.Identity.Name;
            e.NewValues["ApprovalDate"] = DateTime.Now;
        //}
        //else
        //    throw new Exception("Only the Dean Can Make Approvals");
    }
    protected void gvExam_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = UnwrapExceptionMessage(e.Exception);
    }
    protected void gvExam_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 40;
    }
    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }
    protected void cmdprint_Click(object sender, EventArgs e)
    {
        pop_print.ContentUrl = "~/COOPERP/Timetables/XtraReports/Default.aspx";
        pop_print.Width = 900;
        pop_print.Height = 500;
        Session["Report"] = "ExamPaper";

        pop_print.ShowOnPageLoad = true;
    }
    protected void cmdComment_Click(object sender, EventArgs e)
    {
        gvExam.AddNewRow();
    }
    protected void gvExam_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        e.NewValues["approved_by"] = HttpContext.Current.User.Identity.Name;
        e.NewValues["ApprovalDate"] = DateTime.Now;
        e.NewValues["ExamID"] = ulong.Parse(Session["mid"].ToString());
    }
    protected void gvExam_RowInserted(object sender, DevExpress.Web.Data.ASPxDataInsertedEventArgs e)
    {
        com.UpdateMainComments(ulong.Parse(Session["mid"].ToString()));
    }
    protected void gvExam_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        com.UpdateMainComments(ulong.Parse(Session["mid"].ToString()));
    }
}