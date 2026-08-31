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

    /// <summary>
    /// True when the request carries a signed-in staff session.
    ///
    /// These PageMethods were reachable by anyone: a POST with no cookies to
    /// IDCardController.aspx/Action ran the state machine, and Actor() then signed the
    /// audit trail "admin". Verified against production before this was added — Stats
    /// returned the live counts and Action reached the engine. Every method below now
    /// refuses an unauthenticated caller.
    ///
    /// Accepts either signal the eadmin screens use, because different entry points
    /// establish one or the other and requiring both would lock out real staff.
    /// </summary>
    private static bool Authed()
    {
        var ctx = HttpContext.Current;
        if (ctx == null) return false;
        try
        {
            if (ctx.User != null && ctx.User.Identity != null && ctx.User.Identity.IsAuthenticated
                && !string.IsNullOrEmpty(ctx.User.Identity.Name)) return true;
        }
        catch { }
        try
        {
            if (ctx.Session != null)
            {
                object u = ctx.Session["username"];
                if (u != null && !string.IsNullOrEmpty(u.ToString().Trim())) return true;
            }
        }
        catch { }
        return false;
    }

    /// <summary>
    /// The refusal. A PageMethod cannot usefully return 401 — FormsAuthenticationModule
    /// turns it into a 302 to the login page and the caller receives HTML where it
    /// expected JSON, reporting "request failed" instead of "your session expired".
    /// </summary>
    private const string Denied = "{\"success\":false,\"message\":\"Your session has expired. Please sign in again, then retry.\"}";

    [WebMethod(EnableSession = true)]
    public static string Stats() { return Authed() ? IDCardService.StatsJson() : Denied; }

    /// <summary>Statuses and the legal-transition map, so the console's status picker
    /// can mark which moves are ordinary and which need an override.</summary>
    [WebMethod(EnableSession = true)]
    public static string Meta() { return Authed() ? IDCardService.MetaJson() : Denied; }

    /// <summary>
    /// Move a request to any status. A legal move behaves exactly like the ordinary
    /// action buttons; anything else needs override=true and a reason, and is written
    /// into the request's history as an override. See IDCardService.SetStatusJson.
    /// </summary>
    [WebMethod(EnableSession = true)]
    public static string SetStatus(string requestNo, string toStatus, string reason, bool allowOverride)
    {
        if (!Authed()) return Denied;
        return IDCardService.SetStatusJson(requestNo, toStatus, reason, Actor(), "admin", "eadmin", allowOverride);
    }

    [WebMethod(EnableSession = true)]
    public static string List(string status, string type, string cardType, string q, int page, int size)
    { return Authed() ? IDCardService.ListJson(status, type, cardType, q, page, size <= 0 ? 50 : size) : Denied; }

    [WebMethod(EnableSession = true)]
    public static string Detail(string requestNo) { return Authed() ? IDCardService.DetailJson(requestNo) : Denied; }

    [WebMethod(EnableSession = true)]
    public static string Action(string requestNo, string action, string reason, string collectionPoint)
    { return Authed() ? IDCardService.ActionJson(requestNo, action, reason, collectionPoint, Actor(), "admin", "eadmin") : Denied; }

    /// <summary>
    /// Apply one action to many requests. Each is run through the same state-machine
    /// funnel as Action(); requests in an incompatible state simply fail (reported
    /// per-item) without affecting the others.
    /// </summary>
    [WebMethod(EnableSession = true)]
    public static string BatchAction(string requestNos, string action, string reason, string collectionPoint)
    { return Authed() ? IDCardService.BatchActionJson(requestNos, action, reason, collectionPoint, Actor(), "admin", "eadmin", 500) : Denied; }

    [WebMethod(EnableSession = true)]
    public static string Windows() { return Authed() ? IDCardService.WindowsJson() : Denied; }

    [WebMethod(EnableSession = true)]
    public static string CreateWindow(string title, string scope, string opensAt, string closesAt, string notes)
    { return Authed() ? IDCardService.CreateWindowJson(title, scope, opensAt, closesAt, notes, Actor()) : Denied; }

    [WebMethod(EnableSession = true)]
    public static string SetWindow(int id, bool active) { return Authed() ? IDCardService.SetWindowActiveJson(id, active) : Denied; }
}
