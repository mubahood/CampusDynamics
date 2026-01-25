using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_BankReconciliation : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_msgbox.HeaderText = "Campus Dynamics ERP";
        if (!IsPostBack)
        {
            txtStartDate.Value = DateTime.Parse(DateTime.Today.Month+"/"+1+"/"+DateTime.Today.Year);
            txtEndDate.Value = DateTime.Today;
        }
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 600;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        Session["bankcode"] = txtPayee.Value;
        Session["RID"] = txtStatement.Value;
        Session["Report"] = "Reconciliation";
        pop_msgbox.ShowOnPageLoad = true;
        gvBankStatementRecords.DataBind();
    }
    protected void imgDetails_Click(object sender, ImageClickEventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 400;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/TransactionDetails.aspx";
        Session["Vno"] = gvLedger.GetRowValues(gvLedger.FocusedRowIndex, "voucherno");
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        try
        {
            CoopERPDataTableAdapters.fin_reconciliationstatementTableAdapter RECO = new CoopERPDataTableAdapters.fin_reconciliationstatementTableAdapter();
            RECO.Insert(DateTime.Today, double.Parse(RECO.fin_GetLastRecoBalance(DateTime.Today).ToString()), DateTime.Today, 0, "Pending", txtPayee.Value.ToString(), "RECONCILIATION STATEMENT [" + DateTime.Today.ToString("dd MMMM, yyyy").ToUpper() + "]");
            gvBankStatementRecords.DataBind();
            txtStatement.DataBind();
            txtStatement.SelectedIndex = -1;
            lbl_msgbox.Text = "New Statement Created. Select from Statement Dropdownlist to Edit";
            pop_msgbox.ShowOnPageLoad = true;
        }
        catch (Exception ex) 
        {
            lbl_msgbox.Text = "Error ! ["+ex.Message+"]";
            pop_msgbox.ShowOnPageLoad = true;
        }
    }
    protected void txtPayee_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtStatement.DataBind();
        gvCurrentReconciliationStatement.DataBind();
        gvBankStatementRecords.DataBind();
       // txtStatement.SelectedIndex = 0;
    }
    protected void txtStatement_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvCurrentReconciliationStatement.DataBind();
        gvBankStatementRecords.DataBind();
    }

    protected void cmdImportStatement_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 650;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/ExcellDataLoader.aspx";
        Session["RID"] = txtStatement.Value;
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdAdjustments_Click(object sender, EventArgs e)
    {
       
    }
    protected void cmdMatch_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        CoopERPDataTableAdapters.fin_reconciliationstatementTableAdapter RECO = new CoopERPDataTableAdapters.fin_reconciliationstatementTableAdapter();
        RECO.finPerformAutoReconciliation(int.Parse(txtStatement.Value.ToString()));
        lbl_msgbox.Text = "Auto Reconciliation Completed";
        pop_msgbox.ContentUrl = "";
        gvBankStatementRecords.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdMatchSelected_Click(object sender, EventArgs e)
    {
        int noRows = gvBankStatementRecords.VisibleRowCount;
        lbl_msgbox.Text = "Caution! No Matching Entries Ticked";
        CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter RECO = new CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter();
        
            if (gvBankStatementRecords.Selection.IsRowSelected(gvBankStatementRecords.FocusedRowIndex) && gvLedger.Selection.IsRowSelected(gvLedger.FocusedRowIndex))
            {
                string bank_amount, cr_ledger_amount,dr_ledger_amount,real_amount;
                bank_amount = gvBankStatementRecords.GetRowValues(gvBankStatementRecords.FocusedRowIndex, "amount").ToString();
                dr_ledger_amount = gvLedger.GetRowValues(gvLedger.FocusedRowIndex, "dramount").ToString();
                cr_ledger_amount = gvLedger.GetRowValues(gvLedger.FocusedRowIndex, "cramount").ToString();

                if (dr_ledger_amount == "")
                {
                    real_amount = cr_ledger_amount;
                }
                else
                {
                    real_amount = dr_ledger_amount;
                }

                if (real_amount == bank_amount)
                {
                    RECO.ManualReconcile(int.Parse(gvLedger.GetRowValues(gvLedger.FocusedRowIndex, "TID").ToString()),
                        int.Parse(gvBankStatementRecords.GetRowValues(gvBankStatementRecords.FocusedRowIndex, "ID").ToString()));
                    lbl_msgbox.Text = "Reconciliation Completed Successfully";
                }
                else
                {
                    lbl_msgbox.Text = "Error! Amount Missmatch Detected";
                }
            }

        gvBankStatementRecords.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
        
    }
    protected void cmdUnmatchMatch_Click(object sender, EventArgs e)
    {
        int noRows = gvBankStatementRecords.VisibleRowCount,counter=0;
        lbl_msgbox.Text = "Caution! No Entries Ticked";
        CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter RECO = new CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            if (gvBankStatementRecords.Selection.IsRowSelected(i))
            {
                counter++;
                RECO.UnReconcile(int.Parse(gvBankStatementRecords.GetRowValues(i,"ID").ToString()));
                lbl_msgbox.Text = counter + " Reconciliation(s) Cancelled Successfully";
            }
        }
        
        pop_msgbox.ShowOnPageLoad = true;
        gvBankStatementRecords.DataBind();
    }
    protected void cmdClearBankData_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter RECO = new CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter();
        RECO.ClearTable(int.Parse(txtStatement.Value.ToString()));
        lbl_msgbox.Text = "Data Cleared Successfully";
        pop_msgbox.ContentUrl = "";
        pop_msgbox.ShowOnPageLoad = true;
        gvBankStatementRecords.DataBind();
        gvLedger.DataBind();
    }
    protected void cmdAdjustmentsData_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 550;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/RecoAdjustments.aspx";
        Session["RID"] = txtStatement.Value;
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdRefreshData_Click(object sender, EventArgs e)
    {
        gvBankStatementRecords.DataBind();
        gvCurrentReconciliationStatement.DataBind();
        gvLedger.DataBind();
    }
    protected void cmdManageData_Click(object sender, EventArgs e)
    {
        pop_managedata.ShowOnPageLoad = true;
    }


    protected void cmdAdd_Adjustment_Click(object sender, EventArgs e)
    {
        int noRows = gvBankStatementRecords.VisibleRowCount, counter = 0;
        lbl_adjustments.Text = "Caution! No Bank Statement Trasctions Ticked";
        //cmdAddNewAdjustments.Enabled = false;
        //txtAdjustmentCategory.Enabled = false;
        for (int i = 0; i < noRows; i++)
        {
            if (gvBankStatementRecords.Selection.IsRowSelected(i) && gvBankStatementRecords.GetRowValues(i,"match_TID").ToString()=="0")
            {
                counter++;
                lbl_adjustments.Text = counter + " Transactions Ready for Posting";
                //cmdAddNewAdjustments.Enabled = true;
                //txtAdjustmentCategory.Enabled = true;
            }
        }
        pop_adjustments.Width = 450;
        pop_adjustments.Height = 300;
        pop_adjustments.ShowOnPageLoad = true;
    }
    protected void cmdAddNewAdjustments_Click(object sender, EventArgs e)
    {
        int noRows = gvBankStatementRecords.VisibleRowCount, counter = 0;
        CoopERPDataTableAdapters.fin_reco_adjustmentsTableAdapter RECO_ADJ = new CoopERPDataTableAdapters.fin_reco_adjustmentsTableAdapter();
        CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter RECO = new CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter();

        lbl_msgbox.Text = "Caution! No Valid Trasctions Ticked";
        string typ="Add";
        if (txtAdjustmentCategory.Text == "Uncredited Deposits" || txtAdjustmentCategory.Text == "Direct Debits")
        {
            typ = "Less";
        }
        for (int i = 0; i < noRows; i++)
        {
            if (gvBankStatementRecords.Selection.IsRowSelected(i) && gvBankStatementRecords.GetRowValues(i, "match_TID").ToString() == "0")
            {
                counter++;
                try
                {
                    RECO.ManualReconcile(101, int.Parse(gvBankStatementRecords.GetRowValues(i, "ID").ToString()));
                    RECO_ADJ.Insert(txtAdjustmentCategory.Text, typ, uint.Parse(txtStatement.Value.ToString()), txtPayee.Value.ToString(), double.Parse(gvBankStatementRecords.GetRowValues(i, "amount").ToString()),
                        gvBankStatementRecords.GetRowValues(i, "details").ToString());
                   
                    lbl_msgbox.Text = counter + " Transactions Posted";
                }
                catch (Exception) { }
            }
        }
        gvBankStatementRecords.DataBind();
        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        pop_msgbox.ShowOnPageLoad = true;
    }
}
   