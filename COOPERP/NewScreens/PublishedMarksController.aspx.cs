using System;
using System.Web.Services;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_PublishedMarksController : System.Web.UI.Page
{
    private const AdminMarksPageKind PageKind = AdminMarksPageKind.Published;

    protected void Page_Load(object sender, EventArgs e)
    {
        using (MySqlConnection conn = new MySqlConnection(MarksControllerShared.ConnectionString))
        {
            conn.Open();
            MarksControllerShared.EnsureProvisionalColumns(conn);
            MarksControllerShared.LoadFilters(Request, conn, ddlYear, ddlSemester, ddlStatus, ddlProg, ddlLecturer, ddlPageSize, txtSearch, PageKind);
            MarksControllerShared.LoadStats(conn, litStatTotal, litPending, litApproved, litRejected, litPublished, litNotEntered);
            MarksControllerShared.BindGrid(Request, conn, ddlYear, ddlSemester, ddlStatus, ddlProg, ddlLecturer, ddlPageSize, txtSearch, litRows, litFrom, litTo, litTotal, litTotal2, litPage, litPageCount, litPager, litPager2, PageKind);
        }
    }

    [WebMethod] public static string GetProvisionalRecord(int id) { return MarksControllerShared.GetProvisionalRecord(id); }
    [WebMethod] public static string GetRecordDetails(int id) { return MarksControllerShared.GetRecordDetails(id); }
    [WebMethod] public static string ReviewProvisionalMarks(int id, string action, string comment) { return MarksControllerShared.ReviewProvisionalMarks(id, action, comment); }
    [WebMethod] public static string PublishMarks(int id) { return MarksControllerShared.PublishMarks(id); }
    [WebMethod] public static string SaveAdminMarks(int id, int? cw, int? exam, int? total, string note) { return MarksControllerShared.SaveAdminMarks(id, cw, exam, total, note); }
    [WebMethod] public static string ResetToPending(int id) { return MarksControllerShared.ResetToPending(id); }
    [WebMethod] public static string UnpublishMark(int id, string comment) { return MarksControllerShared.UnpublishMark(id, comment); }
    [WebMethod] public static string ReprocessPublishedMark(int id) { return MarksControllerShared.ReprocessPublishedMark(id); }
    [WebMethod] public static string BulkAction(int[] ids, string action, string comment) { return MarksControllerShared.BulkAction(ids, action, comment); }
    [WebMethod] public static string PreviewBatchWorkflow(string action, string scope, int[] ids, string year, string sem, string prog) { return MarksControllerShared.PreviewBatchWorkflow(action, scope, ids, year, sem, prog, PageKind); }
    [WebMethod] public static string ExecuteBatchWorkflow(string action, string scope, int[] ids, string year, string sem, string prog, string comment) { return MarksControllerShared.ExecuteBatchWorkflow(action, scope, ids, year, sem, prog, comment, PageKind); }
}
