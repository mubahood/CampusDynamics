using System;
using System.Web;
using System.Web.Services;
using System.Web.UI;

// eAdmin — Course Deletion Requests. Thin page: the work is in CourseDeletionService.
// Page view is auth-gated by SidebarMaster.master; the WebMethods bypass the master, so
// they carry their own session guard.
public partial class COOPERP_NewScreens_CourseDeletionRequests : Page
{
    protected void Page_Load(object sender, EventArgs e) { }

    private const string DENIED = "{\"success\":false,\"message\":\"Your session has expired. Please sign in again.\"}";

    private static bool NoAuth()
    {
        return HttpContext.Current == null || HttpContext.Current.Session == null
            || HttpContext.Current.Session["username"] == null;
    }

    private static string Actor()
    {
        try
        {
            var s = HttpContext.Current.Session;
            object u = s["username"] ?? s["ScreenName"];
            return u == null ? "admin" : u.ToString();
        }
        catch { return "admin"; }
    }

    [WebMethod(EnableSession = true)]
    public static string List(string status, string q, int page, int pageSize)
    { return NoAuth() ? DENIED : CourseDeletionService.List(status, q, page, pageSize); }

    [WebMethod(EnableSession = true)]
    public static string Detail(int id)
    { return NoAuth() ? DENIED : CourseDeletionService.Detail(id); }

    [WebMethod(EnableSession = true)]
    public static string Approve(int id, string comment)
    { return NoAuth() ? DENIED : CourseDeletionService.Approve(id, Actor(), comment); }

    [WebMethod(EnableSession = true)]
    public static string Reject(int id, string comment)
    { return NoAuth() ? DENIED : CourseDeletionService.Reject(id, Actor(), comment); }

    // Undo an approved deletion — puts the registration and any published result back
    // exactly as they were captured, and re-settles the semester GPA.
    [WebMethod(EnableSession = true)]
    public static string Reverse(int id, string comment)
    { return NoAuth() ? DENIED : CourseDeletionService.Reverse(id, Actor(), comment); }
}
