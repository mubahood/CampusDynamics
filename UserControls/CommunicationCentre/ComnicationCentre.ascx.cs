using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_CommunicationCentre_ComnicationCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdSMS_Click(object sender, EventArgs e)
    {
        pop_sms.Width = 400;
        pop_sms.Height = 400;
        pop_sms.ContentUrl = "~/SMSSender.aspx";
        pop_sms.ShowOnPageLoad = true;
    }
    protected void cmdUpdateList_Click(object sender, EventArgs e)
    {
        if (Session["noReceipients"] == null) { Session["noReceipients"] = 0; }
        int noRows = SmsGridView1.VisibleRowCount, counter = 0, intCurrReceipients = int.Parse(Session["noReceipients"].ToString());

        string comm = "Error! None Selected";
        for (int i = 0; i < noRows; i++)
        {
            if (SmsGridView1.Selection.IsRowSelected(i))
            { 
                counter++;
                if (Session["receipients"] == "-")
                {
                    Session["receipients"] = string.Format("{0}", SmsGridView1.GetRowValues(i, "studPhone"));
                }
                else
                {
                    Session["receipients"] = string.Format("{0},{1}", Session["receipients"], SmsGridView1.GetRowValues(i, "studPhone"));
                    //Response.Write(Session["receipients"]);
                }

                intCurrReceipients++;
                Session["noReceipients"] = intCurrReceipients;

                comm = string.Format("{0} New Added. Total={1}", counter, intCurrReceipients);

            }
        }

        panel_sms.HeaderStyle.ForeColor = System.Drawing.Color.Red;
        panel_sms.HeaderText = comm;
        //lbl_smsComments.Text = comm;
    }
    protected void cmdClearList_Click(object sender, EventArgs e)
    {
        Session["receipients"] = "-";
        Session["noReceipients"] = 0;
        panel_sms.HeaderStyle.ForeColor = System.Drawing.Color.Red;
        panel_sms.HeaderText = "List Cleared";
    }
}