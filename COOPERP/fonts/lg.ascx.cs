using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_fonts_lg : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_lock.Width = 500;
        pop_lock.ShowOnPageLoad = true;
        Session["otp"] = null;
        
    }

    protected void Login1_LoggingIn1(object sender, LoginCancelEventArgs e)
    {
        Session["username"] = Login1.UserName;

    }
    protected void Login1_LoggedIn(object sender, EventArgs e)
    {
        Session["username"] = Login1.UserName;
        System.Web.UI.WebControls.Login senderLogin = sender as System.Web.UI.WebControls.Login;
        string key = senderLogin.UserName + senderLogin.Password;
        TimeSpan TimeOut = new TimeSpan(0, 0, HttpContext.Current.Session.Timeout, 0, 0);
        HttpContext.Current.Cache.Insert(key,
            Session.SessionID,
            null,
            DateTime.MaxValue,
            TimeOut,
            System.Web.Caching.CacheItemPriority.NotRemovable,
            null);

        Session["usernm"] = key;
        
      
    }


   
}