using System;
using System.Web;

public partial class COOPERP_NewScreens_AccessDenied : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.StatusCode = 403;
        Response.TrySkipIisCustomErrors = true;

        string slug = Request.QueryString["slug"];
        if (!string.IsNullOrEmpty(slug))
        {
            litSlug.Text = "<div class=\"ad-slug\">Required permission: " +
                           HttpUtility.HtmlEncode(slug) + "</div>";
        }
    }
}
