using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;

public partial class UserControls_financials_StudentLedger : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtAdmNo.Text = Session["regno"].ToString();
        lbl_header.Text = string.Format("STUDENT LEDGER FOR {0} [{1}]", Session["stud_name"], Session["regno"]).ToUpper();
        if (!IsPostBack)
        {
            txtStartDate.Value =DateTime.Parse(Session["sDate"].ToString());
            txtEndDate.Value = DateTime.Parse(Session["eDate"].ToString());
        }
        if (txtType.Text == "Correct Pay Amount")
        {
            txtNewAmount.Enabled = true;
        }
        else
        {
            txtNewAmount.Enabled = false;
        }
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
         
        Session["accno"] = Session["regno"];
        Session["sDate"] = txtStartDate.Date;
        Session["eDate"] = txtEndDate.Date;
        Session["Report"] = "StudentLedger";
        Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
    }
    protected void cmdProcess_Click(object sender, EventArgs e)
    {
        AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter ADJ = new AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter();
        int noRows = gvLedger.VisibleRowCount, counter = 0 ;
        if (txtType.Text.Contains("Reverse"))
        {
            if (txt_reason.Text == "")
            {
                lbl_msgbox.Text = "Error! You MUST enter a reason for the reversal";
            }
            else
            {
                for (int i = 0; i < noRows; i++)
                {
                    if (gvLedger.Selection.IsRowSelected(i))
                    {
                        ADJ.fin_TransactionReversal(int.Parse(gvLedger.GetRowValues(i, "realVoucherno").ToString()),
                            HttpContext.Current.User.Identity.Name, txt_reason.Text);
                        counter++;
                    }
                }
                lbl_msgbox.Text = counter + " transactions reversed successfully";
                gvLedger.DataBind();
            }
            pop_msgbox.ShowOnPageLoad = true;
        }
        else if (txtType.Text.Contains("Billing Correction"))
        {
            ADJ.fin_CorrectionBilling(Session["regno"].ToString(), Session["acad"].ToString(), int.Parse(Session["sems"].ToString()), "REG",
                HttpContext.Current.User.Identity.Name,Session["residence"].ToString());

            lbl_msgbox.Text = "Correction billing completed";
            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Correct Pay Amount"))
        {
            
            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    string details = gvLedger.GetRowValues(i, "particulars").ToString(), vno = gvLedger.GetRowValues(i, "realVoucherno").ToString();
                    DateTime Tdate = DateTime.Parse(gvLedger.GetRowValues(i, "transactionDate").ToString());
                    if (Tdate == DateTime.Today)
                    {
                        if (details.Contains("Paid By"))
                        {
                            ADJ.fin_UpdatePayAmount(vno, HttpContext.Current.User.Identity.Name, double.Parse(txtNewAmount.Text.Replace(",", "")));
                            lbl_msgbox.Text = "Pay Amount Correction completed";
                        }
                        else
                        {
                            lbl_msgbox.Text = "Sorry! Only manual transaction amounts can be corrected";
                        }
                    }
                    else
                    {
                        lbl_msgbox.Text = "Sorry! Only today's transaction amounts can be corrected";
                    }
                }
            }

            
            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Cancel Payment"))
        {
            lbl_msgbox.Text = "No Transaction selected";
            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    string details = gvLedger.GetRowValues(i, "particulars").ToString();
                    if (details.Contains("Fees Payment") || details.Contains("Paid By"))
                    {
                        ADJ.CancelTransaction(int.Parse(gvLedger.GetRowValues(i, "realVoucherno").ToString()));
                        counter++;
                        lbl_msgbox.Text = counter + " payments cancelled successfully";
                    }
                    else
                    {
                        lbl_msgbox.Text = "Sorry! only payments can be cancelled";
                        break;
                    }
                }
            }
            
            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Clear Ledger"))
        {
            ADJ.fin_ClearLedger(Session["regno"].ToString(), "Student", HttpContext.Current.User.Identity.Name);
            lbl_msgbox.Text = "Ledger Cleared";
            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
    }
}