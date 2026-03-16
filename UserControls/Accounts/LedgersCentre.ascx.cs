using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;
using CoopERPDataTableAdapters;
using System.Transactions;

public partial class UserControls_Accounts_LedgersCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_msgbox.HeaderText = "Campus Dynamics ERP";
        if (!IsPostBack)
        {
            if (DateTime.Today.Month > 7)
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
            else
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year - 1); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
            txtLedgerType.Text = "Chart Account";
            txtPayeeCategory.Text = "Chart Account";
            txtEndDate.Value = DateTime.Today;

            
        }

        if (txtType.Text == "Correct Amount")
        {
            txtNewAmount.Enabled = true;
            txt_reason.Enabled = false;

        }
        else if (txtType.Text == "Reverse Transaction")
        {
            txtNewAmount.Enabled = false;
            txt_reason.Enabled = true;
        }
        else
        {
            txtNewAmount.Enabled = false;
            txt_reason.Enabled = false;
        }
        
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 800;
        pop_msgbox.Height = 600;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        Session["accno"] = txtPayee.Value;
        Session["startDate"] = txtStartDate.Text;
        Session["endDate"] = txtEndDate.Text;
        Session["Report"] = "Legder";
        Session["typ"] = txtLedgerType.Text;
        Session["disp_curr"] = txtDisplayCurrency.Text;

        pop_msgbox.ShowOnPageLoad = true;
        gvLedger.DataBind();
    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 400;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/TransactionDetails.aspx";
        Session["Vno"] = gvLedger.GetRowValues(gvLedger.FocusedRowIndex, "voucherno");
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void gvLedger_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void cmdProcess_Click(object sender, EventArgs e)
    {
        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 350;
        pop_msgbox.Height = 145;

        // B13 FIX: Block all ledger operations outside open financial period
        string periodError;
        if (!IsInOpenFinancialPeriod(out periodError))
        {
            lbl_msgbox.Text = periodError;
            pop_msgbox.ShowOnPageLoad = true;
            return;
        }

        AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter ADJ = new AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter();
        int noRows = gvLedger.VisibleRowCount, counter = 0;
        if (txtType.Text.Contains("Reverse"))
        {
            // B4 FIX: Only Administrator or Bursar can reverse transactions
            if (!HttpContext.Current.User.IsInRole("Administrator") && !HttpContext.Current.User.IsInRole("Bursar"))
            {
                lbl_msgbox.Text = "Sorry! Only Administrator or Bursar can reverse transactions";
            }
            else if (txt_reason.Text == "")
            {
                lbl_msgbox.Text = "Error! You MUST enter a reason for the reversal";
            }
            else
            {
                // C6 FIX: Wrap multi-row reversal in TransactionScope
                using (TransactionScope scope = new TransactionScope())
                {
                    for (int i = 0; i < noRows; i++)
                    {
                        if (gvLedger.Selection.IsRowSelected(i))
                        {
                            ADJ.fin_TransactionReversal(int.Parse(gvLedger.GetRowValues(i, "voucherno").ToString()),
                                HttpContext.Current.User.Identity.Name, txt_reason.Text);
                            counter++;
                        }
                    }
                    scope.Complete();
                }
                lbl_msgbox.Text = counter + " transactions reversed successfully";
                gvLedger.DataBind();
            }
            pop_msgbox.ShowOnPageLoad = true;
           
        }
        
        else if (txtType.Text.Contains("Correct Amount"))
        {
            // C6 FIX: Wrap corrections in TransactionScope
            using (TransactionScope scope = new TransactionScope())
            {
                for (int i = 0; i < noRows; i++)
                {
                    if (gvLedger.Selection.IsRowSelected(i))
                    {
                        string details = gvLedger.GetRowValues(i, "particulars").ToString(), vno = gvLedger.GetRowValues(i, "voucherno").ToString();
                        DateTime Tdate = DateTime.Parse(gvLedger.GetRowValues(i, "transactiondate").ToString());
                        if (Tdate == DateTime.Today)
                        {
                            if (HttpContext.Current.User.IsInRole("Bursar"))
                            {
                                ADJ.fin_UpdatePayAmount(vno, HttpContext.Current.User.Identity.Name, double.Parse(txtNewAmount.Text.Replace(",", "")));
                                lbl_msgbox.Text = "Pay Amount Correction completed";
                            }
                            else
                            {
                                lbl_msgbox.Text = "Sorry! Only Bursar can make amounts corrections";
                                return; // exits without scope.Complete() — rolls back
                            }
                        }
                        else
                        {
                            lbl_msgbox.Text = "Sorry! Only today's transaction amounts can be corrected";
                            return; // exits without scope.Complete() — rolls back
                        }
                    }
                }
                scope.Complete();
            }

            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Cancel Transaction"))
        {
            lbl_msgbox.Text = "No Transaction selected";
            // C6 FIX: Wrap multi-row cancellation in TransactionScope
            using (TransactionScope scope = new TransactionScope())
            {
                for (int i = 0; i < noRows; i++)
                {
                    if (gvLedger.Selection.IsRowSelected(i))
                    {
                        string details = gvLedger.GetRowValues(i, "particulars").ToString();
                        if (HttpContext.Current.User.IsInRole("Bursar"))
                        {
                            ADJ.CancelTransaction(int.Parse(gvLedger.GetRowValues(i, "voucherno").ToString()));
                            counter++;
                            lbl_msgbox.Text = counter + " transaction(s) cancelled successfully";
                        }
                        else
                        {
                            lbl_msgbox.Text = "Sorry! only Bursar can cancel transactions";
                            return; // exits without scope.Complete() — rolls back
                        }
                    }
                }
                scope.Complete();
            }

            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
        else if (txtType.Text.Contains("Clear Ledger"))
        {
            // B3 FIX: Only Administrator can clear entire ledger (nuclear operation)
            if (!HttpContext.Current.User.IsInRole("Administrator"))
            {
                lbl_msgbox.Text = "Sorry! Only Administrator can clear a ledger";
            }
            else
            {
                ADJ.fin_ClearLedger(txtPayee.Value.ToString(), txtPayeeCategory.Value.ToString(),
                    HttpContext.Current.User.Identity.Name);
                lbl_msgbox.Text = "Ledger Cleared";
            }
            pop_msgbox.ShowOnPageLoad = true;
            gvLedger.DataBind();
        }
    }
    // B13 FIX: Financial period validation
    private bool IsInOpenFinancialPeriod(out string errorMessage)
    {
        errorMessage = "";
        fin_financial_yearsTableAdapter FY = new fin_financial_yearsTableAdapter();
        var dtOpen = FY.GetFinicalPeriodStatus();
        if (dtOpen.Rows.Count == 0)
        {
            errorMessage = "Error! No financial year is currently Open. Cannot perform ledger operations.";
            return false;
        }
        DateTime periodStart = Convert.ToDateTime(dtOpen.Rows[0]["start_date"]);
        DateTime periodEnd = Convert.ToDateTime(dtOpen.Rows[0]["end_date"]);
        DateTime today = DateTime.Today;
        if (today < periodStart || today > periodEnd)
        {
            errorMessage = "Error! Cannot modify ledger. Accounting Period Closed. The Date Ranges are: "
                           + periodStart.ToString("dd/MM/yyyy") + " - " + periodEnd.ToString("dd/MM/yyyy") + ".";
            return false;
        }
        return true;
    }
}