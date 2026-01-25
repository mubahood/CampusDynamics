using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CoopERPDataTableAdapters;
using Systems.Settings.SD;

public partial class UserControls_Accounts_JournalDetails : System.Web.UI.UserControl
{
    string UserName = HttpContext.Current.User.Identity.Name;
    SettingsFile setting = new SettingsFile();
    fin_journalTableAdapter Journal = new fin_journalTableAdapter();
    fin_journalnumbersTableAdapter JNumbers = new fin_journalnumbersTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        lbl_header.Text = Session["header"].ToString();
        lbl_memo.Text = Session["memo"].ToString();

        if (Session["PostStatus"].ToString() == "Posted")
        {
            cmdNew.Enabled = false;
        }

        pop_msgbox.HeaderText = HomePageManager.SystemName();
    }
 
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        try
        {
            
            Journal.fin_SingleJournalCreator(txtPayee.Value.ToString(), txtLedgerType.Text, long.Parse(txtAmount.Text.Replace(",","")),
                int.Parse(Session["JNo"].ToString()), UserName, txtDR_CR.Text);
            img_msg.ImageUrl = setting.InfoImage("OK");
            lbl_msgbox.ForeColor = setting.InfoColor("OK");
            lbl_msgbox.Text = "Transaction Added Successfully";
        }
        catch (Exception)
        {
            img_msg.ImageUrl = setting.InfoImage("Error");
            lbl_msgbox.ForeColor = setting.InfoColor("Error");
            lbl_msgbox.Text = "Error! Check Your Data and Try again";
        }

        gvJournalEntries.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdPost_Click(object sender, EventArgs e)
    {
        string comm = "";
        try
        {

            comm=JNumbers.fin_ApproveJournal(int.Parse(Session["JNo"].ToString())).ToString();
            if (comm.Contains("Error"))
            {
                img_msg.ImageUrl = setting.InfoImage("Error");
                lbl_msgbox.ForeColor = setting.InfoColor("Error");
            }
            else
            {
                img_msg.ImageUrl = setting.InfoImage("OK");
                lbl_msgbox.ForeColor = setting.InfoColor("OK");
            }
        }
        catch (Exception ex)
        {
            img_msg.ImageUrl = setting.InfoImage("Error");
            lbl_msgbox.ForeColor = setting.InfoColor("Error");
            comm = "Error! Check Your Data and Try again. "+ex.Message;
        }
        lbl_msgbox.Text = comm;
        gvJournalEntries.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
    }
}