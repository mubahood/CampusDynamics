using System;
using System.Web.Services;
using System.Web.UI;

public partial class COOPERP_NewScreens_MarkPublishController : Page
{
    private const string STAGE = "PUBLISH";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (string.Equals(Request.QueryString["export"], "csv", StringComparison.OrdinalIgnoreCase))
        {
            int rid; int.TryParse(Request.QueryString["rid"], out rid);
            if (rid > 0) StageConsoleShared.ExportRecordCsv(Response, STAGE, rid);
        }
    }

    [WebMethod(EnableSession = true)] public static string Init() { return StageConsoleShared.Init("PUBLISH"); }
    [WebMethod(EnableSession = true)] public static string Stats() { return StageConsoleShared.Stats("PUBLISH"); }
    [WebMethod(EnableSession = true)] public static string Browse(string year, string sem, string prog, string q, int page, int pageSize, bool? failedOnly) { return StageConsoleShared.Browse("PUBLISH", year, sem, prog, q, page, pageSize, failedOnly ?? false); }
    [WebMethod(EnableSession = true)] public static string CreateAndPreview(string prog, int yos, string acadYear, int sem, bool all, string notes, string failMode) { return StageConsoleShared.CreateAndPreview("PUBLISH", prog, yos, acadYear, sem, all, notes, failMode); }
    [WebMethod(EnableSession = true)] public static string Commit(int recordId) { return StageConsoleShared.Commit("PUBLISH", recordId); }
    [WebMethod(EnableSession = true)] public static string Cancel(int recordId) { return StageConsoleShared.Cancel("PUBLISH", recordId); }
    [WebMethod(EnableSession = true)] public static string ReturnMarks(int[] ids, string reason) { return StageConsoleShared.ReturnMarks("PUBLISH", ids, reason); }
    [WebMethod(EnableSession = true)] public static string Records(int page) { return StageConsoleShared.Records("PUBLISH", page); }
    [WebMethod(EnableSession = true)] public static string RecordDetail(int recordId) { return StageConsoleShared.RecordDetail("PUBLISH", recordId); }
}
