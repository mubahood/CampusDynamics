<%@ Application Language="C#" %>

<script runat="server">

    void Application_BeginRequest(object sender, EventArgs e)
    {
        // Enforce HTTPS across the entire application
        // Skip for local development requests
        if (HttpContext.Current.Request.IsLocal)
            return;

        // Check if already secure (direct SSL or behind a reverse proxy)
        bool isSecure = HttpContext.Current.Request.IsSecureConnection;
        string forwardedProto = HttpContext.Current.Request.Headers["X-Forwarded-Proto"];
        if (!string.IsNullOrEmpty(forwardedProto))
            isSecure = forwardedProto.Equals("https", StringComparison.OrdinalIgnoreCase);

        if (!isSecure)
        {
            string url = "https://" + HttpContext.Current.Request.Url.Host
                       + HttpContext.Current.Request.Url.PathAndQuery;
            Response.Redirect(url, true);
        }
    }

    void Application_Start(object sender, EventArgs e) 
    {
        // Code that runs on application startup
        Application["UsersLoggedIn"] = new System.Collections.Generic.List<string>();

    }
    
    void Application_End(object sender, EventArgs e) 
    {
        //  Code that runs on application shutdown

    }
        
    void Application_Error(object sender, EventArgs e) 
    { 
        // Code that runs when an unhandled error occurs

    }

    void Session_Start(object sender, EventArgs e) 
    {
        // Code that runs when a new session is started

    }

    void Session_End(object sender, EventArgs e) 
    {
        

    }
    protected void Application_PreRequestHandlerExecute(Object sender, EventArgs e)
    {
        if (HttpContext.Current.Session != null)
        {
            if (Session["usernm"] != null)
            {
                string cacheKey = Session["usernm"].ToString();
                string cachedSessionId = (string)HttpContext.Current.Cache[cacheKey];

                if (cachedSessionId == null)
                {
                    // Cache was lost (app pool recycle) but user still has a valid
                    // session — re-register rather than forcing logout.
                    TimeSpan cacheTimeout = TimeSpan.FromHours(24);
                    HttpContext.Current.Cache.Insert(cacheKey,
                        Session.SessionID,
                        null,
                        DateTime.MaxValue,
                        cacheTimeout,
                        System.Web.Caching.CacheItemPriority.NotRemovable,
                        null);
                }
                else if (cachedSessionId != Session.SessionID)
                {
                    // A different session logged in with the same credentials
                    // — enforce single-session rule.
                    FormsAuthentication.SignOut();
                    Session.Abandon();
                    Response.Redirect("~/MultiLogin.aspx");
                }
            }
        }
    }

       
</script>
