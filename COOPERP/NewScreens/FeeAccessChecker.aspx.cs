using System;
using System.Web;

public partial class COOPERP_NewScreens_FeeAccessChecker : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Resolve the API base URL relative to the application root
            string appRoot = ResolveUrl("~/");
            hfApiBase.Value = appRoot.TrimEnd('/') + "/API/v2/finance.aspx";

            // Create a staff token so the JS can call the API.
            // TokenManager is in App_Code – reuse it directly.
            string userId = CurrentUser();
            try
            {
                TokenInfo ti = TokenManager.CreateToken(
                    userId,
                    "staff",
                    userId,
                    Request.UserHostAddress);
                hfAdminToken.Value = ti.Token;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("FeeAccessChecker token error: " + ex.Message);
                // Page will still load – JS will just get an auth error from the API
            }
        }
    }

    private string CurrentUser()
    {
        if (Session["user"] != null) return Session["user"].ToString();
        if (Session["username"] != null) return Session["username"].ToString();
        return "admin";
    }
}
