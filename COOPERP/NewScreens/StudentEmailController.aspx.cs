using System;
using System.Web;
using System.Web.Services;
using System.Web.UI;

// eAdmin — Student Email Controller (SEMS). Thin page: all logic is in SemsAdmin.
// Page view is auth-gated by SidebarMaster.master; the WebMethods (which bypass the
// master) carry their own session guard.
public partial class COOPERP_NewScreens_StudentEmailController : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e) { }

    private const string DENIED = "{\"success\":false,\"message\":\"Your session has expired. Please sign in again.\"}";
    private static bool NoAuth()
    {
        return HttpContext.Current == null || HttpContext.Current.Session == null
            || HttpContext.Current.Session["username"] == null;
    }

    [WebMethod(EnableSession = true)]
    public static string Stats() { return NoAuth() ? DENIED : SemsAdmin.Stats(); }

    [WebMethod(EnableSession = true)]
    public static string GenerateEligible() { return NoAuth() ? DENIED : SemsAdmin.GenerateEligible(); }

    [WebMethod(EnableSession = true)]
    public static string Search(string q, string stage, string campus, string programme, string year, string verification, int page, int pageSize)
    { return NoAuth() ? DENIED : SemsAdmin.Search(q, stage, campus, programme, year, verification, page, pageSize); }

    [WebMethod(EnableSession = true)]
    public static string Filters() { return NoAuth() ? DENIED : SemsAdmin.Filters(); }

    [WebMethod(EnableSession = true)]
    public static string CreateEmail(string regno, string email, string tempPw, string notes)
    { return NoAuth() ? DENIED : SemsAdmin.CreateEmail(regno, email, tempPw, notes); }

    [WebMethod(EnableSession = true)]
    public static string Complaints(string status) { return NoAuth() ? DENIED : SemsAdmin.Complaints(status); }

    [WebMethod(EnableSession = true)]
    public static string RespondComplaint(long id, string status, string response)
    { return NoAuth() ? DENIED : SemsAdmin.RespondComplaint(id, status, response); }
}
