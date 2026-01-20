<%@ Application Language="C#" %>

<script runat="server">

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
                if ((string)HttpContext.Current.Cache[cacheKey] != Session.SessionID)
                {
                    FormsAuthentication.SignOut();
                    Session.Abandon();
                    Response.Redirect("~/MultiLogin.aspx");
                }

                string user = (string)HttpContext.Current.Cache[cacheKey];
            }
        }
    }

       
</script>
