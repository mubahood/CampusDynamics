using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace Systems.Settings.SD
{
    public class LoginLoader
    {
        string UserControlPath;
        public string PageLocator()
        {
            if (Licensing.Settings() == true)
            {
                UserControlPath = "/COOPERP/fonts/lg.ascx";
            }
            else
            {
                UserControlPath = "/COOPERP/fonts/Locker.ascx";
            }
            return UserControlPath;
        }
    }
}
