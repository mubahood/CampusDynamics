using System;
using System.Web;
using System.Web.Services;
using System.Web.UI;

/// <summary>
/// eadmin ID Card operations console. Thin WebMethods over IDCardService; the
/// engine owns all logic + the state-machine funnel. Actor resolved from session.
/// </summary>
public partial class COOPERP_NewScreens_IDCardController : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e) { }

    private static string Actor()
    {
        var s = HttpContext.Current != null ? HttpContext.Current.Session : null;
        string u = s != null ? (s["username"] as string) : null;
        return string.IsNullOrEmpty(u) ? "admin" : u;
    }

    [WebMethod(EnableSession = true)]
    public static string Stats() { return IDCardService.StatsJson(); }

    [WebMethod(EnableSession = true)]
    public static string List(string status, string type, string cardType, string q, int page, int size)
    { return IDCardService.ListJson(status, type, cardType, q, page, size <= 0 ? 50 : size); }

    [WebMethod(EnableSession = true)]
    public static string Detail(string requestNo) { return IDCardService.DetailJson(requestNo); }

    [WebMethod(EnableSession = true)]
    public static string Action(string requestNo, string action, string reason, string collectionPoint)
    { return IDCardService.ActionJson(requestNo, action, reason, collectionPoint, Actor(), "admin", "eadmin"); }

    /// <summary>
    /// Apply one action to many requests. Each is run through the same state-machine
    /// funnel as Action(); requests in an incompatible state simply fail (reported
    /// per-item) without affecting the others.
    /// </summary>
    [WebMethod(EnableSession = true)]
    public static string BatchAction(string requestNos, string action, string reason, string collectionPoint)
    { return IDCardService.BatchActionJson(requestNos, action, reason, collectionPoint, Actor(), "admin", "eadmin", 500); }

    [WebMethod(EnableSession = true)]
    public static string Windows() { return IDCardService.WindowsJson(); }

    [WebMethod(EnableSession = true)]
    public static string CreateWindow(string title, string scope, string opensAt, string closesAt, string notes)
    { return IDCardService.CreateWindowJson(title, scope, opensAt, closesAt, notes, Actor()); }

    [WebMethod(EnableSession = true)]
    public static string SetWindow(int id, bool active) { return IDCardService.SetWindowActiveJson(id, active); }
}
