using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using moduleDataTableAdapters;


/// <summary>
/// Summary description for securityBLL
/// </summary>
[System.ComponentModel.DataObject]
public class securityBLL
{
    readonly moduleDataTableAdapters.erp_user_codesTableAdapter userCoder = new moduleDataTableAdapters.erp_user_codesTableAdapter();
    readonly moduleDataTableAdapters.erp_usersTableAdapter users = new moduleDataTableAdapters.erp_usersTableAdapter();
    readonly moduleDataTableAdapters.userNameFinderTableAdapter usernm = new moduleDataTableAdapters.userNameFinderTableAdapter();
    readonly moduleDataTableAdapters.erp_modulesTableAdapter mod = new moduleDataTableAdapters.erp_modulesTableAdapter();
    readonly moduleDataTableAdapters.erp_rolesinmodulesTableAdapter roleModule = new moduleDataTableAdapters.erp_rolesinmodulesTableAdapter();
  
    
    public string AddRoleToModules(string moduleID, string role, string app)
    {
        try
        {
            roleModule.AddRolesToModules(int.Parse(moduleID), role, app);
            return String.Format("Role: {0} successfully added to Module: {1}", role, ModuleNamer(int.Parse(moduleID)));
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }

    public void addUserCode(string userCode, string PK, string userStatus)
    {
        userCoder.addUserCode(userCode, PK, userStatus);
    }
    public string GetPKID(string UserName)
    {
        return users.PKID_finder(UserName);
    }

    public string GetUserName(string status, string userCode)
    {
        return usernm.userNameFinder(status, userCode);
    }
    public string ModuleNamer(int id)
    {
        return mod.moduleNameFinder(id);
    }

    public string UpdateDetails(string userName, string email, string phone)
    {
        try
        {
            erp_GetUserDataTableAdapter user = new erp_GetUserDataTableAdapter();
            user.erp_userDetailsEditor(userName, email, phone);
            return "Updates Completed";
        }
        catch (Exception ex)
        {
            return string.Format("An Error Occured {0}",ex.Message);
        }
    }

    public string RemoveRoleFromModule(string moduleID, string role)
    {

        try
        {
            roleModule.Delete(uint.Parse(moduleID), role);
            return String.Format("Role: {0} successfully Removed From Module: {1}", role, ModuleNamer(int.Parse(moduleID)));
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }
    public bool AdmissionsCheck()
    {
        if (HttpContext.Current.User.IsInRole("Rector")
           || HttpContext.Current.User.IsInRole("Academic Registrar")
           || HttpContext.Current.User.IsInRole("Administrator") || HttpContext.Current.User.IsInRole("Addimisions"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

   

    
}