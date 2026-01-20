using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_UserManagement : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(HttpContext.Current.User.IsInRole("Administrator")==false)
        {
            pc_usermanager.TabPages.FindByName("sysapps").Enabled=false;
            pc_usermanager.TabPages.FindByName("appsettings").Enabled = false;

        }
    }
    protected void gvUsers_FocusedRowChanged(object sender, EventArgs e)
    {
        Session["uid"] = gvUsers.GetRowValues(gvUsers.FocusedRowIndex, "id");
        gvUserRoles.DataBind();
    }
    protected void cmdNewUserRole_Click(object sender, EventArgs e)
    {
        try
        {
            SecurityTableAdapters.my_aspnet_usersinrolesTableAdapter UR = new SecurityTableAdapters.my_aspnet_usersinrolesTableAdapter();
            UR.Insert(int.Parse(gvUsers.GetRowValues(gvUsers.FocusedRowIndex, "id").ToString()), int.Parse(txtNewRole.Value.ToString()));
            
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error! "+ex.Message;
            pop_msgBox.ShowOnPageLoad = true;
        }
        gvUserRoles.DataBind();
    }
    protected void gvUserRoles_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["userId"] = Session["uid"];
    }
    protected void cmdNewRole_Click(object sender, EventArgs e)
    {
        gvRoles.AddNewRow();
    }
    protected void gvRoles_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["applicationId"] = 1;
    }
    protected void cmdDeleteUserRole_Click(object sender, EventArgs e)
    {
        int rows = gvUserRoles.VisibleRowCount;
        SecurityTableAdapters.my_aspnet_usersinrolesTableAdapter uRoles = new SecurityTableAdapters.my_aspnet_usersinrolesTableAdapter();
        for (int i = 0; i < rows; i++)
        {
            //if (gvUserRoles.Selection.IsRowSelected(i) == true)
            //{
            int userID = int.Parse(gvUserRoles.GetRowValues(i, "userId").ToString());
            int roleID = int.Parse(gvUserRoles.GetRowValues(i, "roleId").ToString());
            uRoles.Delete(userID, roleID);
            //}
        }

        gvUserRoles.DataBind();
    }

    protected void cmdReset_Click(object sender, EventArgs e)
    {
        try
        {
            SecurityTableAdapters.my_aspnet_usersTableAdapter Users = new SecurityTableAdapters.my_aspnet_usersTableAdapter();
            Users.ResetPassword(int.Parse(txtUserName.Value.ToString()));
            lbl_resetComment.Text = "Reset Completed";

        }
        catch (Exception ex)
        {
            lbl_resetComment.Text = "Error! " + ex.Message;
        }
    }
    protected void cmdAddUser_Click(object sender, EventArgs e)
    {

    }
    protected void ASPxComboBox3_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void cmdAddUser_Click1(object sender, EventArgs e)
    {
        
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        gvApps.AddNewRow();
    }
   
    
    
    protected void gv_Users_FocusedRowChanged(object sender, EventArgs e)
    {
        
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvUserPhones.AddNewRow();
    }
    protected void CBP_Users_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        Session["uid"] = gvUsers.GetRowValues(gvUsers.FocusedRowIndex, "id");
        Session["curUserName"] = gvUsers.GetRowValues(gvUsers.FocusedRowIndex, "id");
        gvUserRoles.DataBind();
       
    }

    protected void gvUserFaculties_BeforePerformDataSelect(object sender, EventArgs e)
    {
        Session["curUserName"] = gvUsers.GetRowValues(gvUsers.FocusedRowIndex, "name");
        //gvUserFaculties.DataBind();
        //gvUserRoles.DataBind();
    }


    protected void cmdNewUserFaculty_Click(object sender, EventArgs e)
    {
        try
        {
           // SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter UF = new SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter();
           // UF.Insert(gvUsers.GetRowValues(gvUsers.FocusedRowIndex, "name").ToString(), "00");
           // gvUserFaculties.DataBind();

            gvUserFaculties.AddNewRow();
           
        }
        catch (Exception) {
            lbl_msg.Text = "Error! Possible Duplicate Entry for Faculty";
            pop_msgBox.ShowOnPageLoad = true;
        }
    }
    protected void gvUserPhones_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void gvUsers_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = UnwrapExceptionMessage(e.Exception);
    }
    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }
    protected void ASPxPageControl1_ActiveTabChanged(object source, DevExpress.Web.TabControlEventArgs e)
    {

    }
    protected void gvUserFaculties_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        e.NewValues["user_name"] = Session["curUserName"].ToString();
    }
}