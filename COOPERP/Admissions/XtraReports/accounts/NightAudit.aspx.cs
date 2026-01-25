using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_NightAudit : System.Web.UI.Page
{
    int CurrentStage = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
        CurrentStage = int.Parse(rbl_nightaudit.SelectedIndex.ToString());
        ButtonControl();
        UserControl UC = LoadControls();
        rp_controls.Controls.Clear();
        rp_controls.Controls.Add(UC);
    }
    protected void rbl_nightaudit_ValueChanged(object sender, EventArgs e)
    {
        ButtonControl();
        headerManager(rbl_nightaudit.SelectedIndex);
    }

    void ButtonControl()
    {
        rp_controls.HeaderText = rbl_nightaudit.SelectedItem.Text;
        //Next Button
        if (CurrentStage < 5)
        {
            cmdNext.Text = "Next";
            cmdNext.Visible = true;
        }
        else
        {
            //cmdNext.Visible=false;
            cmdNext.Text = "Finish Audit";

        }

        //Previous Button
        if (CurrentStage > 0)
        {

            cmdPrevious.Text = "Previous";
        }
        else
        {
            cmdPrevious.Text = "Start Audit";

        }

    }
    protected void cmdPrevious_Click(object sender, EventArgs e)
    {
       
        
        if (CurrentStage > 0)
        {
            CurrentStage = CurrentStage - 1;
            
            rbl_nightaudit.SelectedIndex = CurrentStage;
            headerManager(CurrentStage);
            rp_controls.HeaderText = rbl_nightaudit.SelectedItem.Text;
            ButtonControl();
            UserControl UC = LoadControls();
            rp_controls.Controls.Clear();
            rp_controls.Controls.Add(UC);
        }
        
    }
    void headerManager(int curStage)
    {
        if (curStage == 3)
        {
            Session["typ"] = "DR";
        }
        else if (curStage == 4)
        {
            Session["typ"] = "CR";
        }
        else if (curStage == 1)
        {
            Session["typ"] = "CheckIn Pending";
        }
        else if (curStage == 2)
        {
            Session["typ"] = "Checked-In";
        }
    }
    protected void cmdNext_Click(object sender, EventArgs e)
    {
        if (CurrentStage < 5)
        {
            CurrentStage = CurrentStage + 1;
            
            rbl_nightaudit.SelectedIndex = CurrentStage;
            headerManager(CurrentStage);
            rp_controls.HeaderText = rbl_nightaudit.SelectedItem.Text;
            ButtonControl();
            UserControl UC = LoadControls();
            rp_controls.Controls.Clear();
            rp_controls.Controls.Add(UC);
        }
        else
        {
            Response.Redirect("~/MyApplications.aspx");
        }


    }

    public UserControl LoadControls()
    {
        string UserControlPath;

        if (CurrentStage == 1)
        {
            UserControlPath = "../../UserControls/Accounts/AuditTodayBookings.ascx";
        }
        else if (CurrentStage == 0)
        {
            UserControlPath = "../../UserControls/Accounts/AuditStartAudit.ascx";
        }
        else if (CurrentStage == 5)
        {
            UserControlPath = "../../UserControls/Accounts/AuditCompleteAudit.ascx";
        }
        else if (CurrentStage == 3)
        {          
            UserControlPath = "../../UserControls/Accounts/AuditTodayBillings.ascx";
        }
        else if (CurrentStage == 4)
        {
            UserControlPath = "../../UserControls/Accounts/AuditTodayBillings.ascx";
        }
        else
        {
            UserControlPath = "../../UserControls/Accounts/AuditTodayBookings.ascx";
        }
        UserControl ctl = Page.LoadControl(UserControlPath) as UserControl;

        // Finally return the fully initialized UC
        return ctl;
    }
}