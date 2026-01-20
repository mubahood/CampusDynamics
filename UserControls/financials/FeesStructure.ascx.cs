using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_FeesStructure : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcademicYear.DataSource = CommonRoutines.ReturnYears();
            txtAcademicYear.DataBind();
            txtAcademicYear.Text = DateTime.Today.Year.ToString();

            txtNewAcademicYear.DataSource = CommonRoutines.ReturnYears();
            txtNewAcademicYear.DataBind();
            txtNewAcademicYear.Text = DateTime.Today.Year.ToString();
        }
        
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter STR = new StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter();
        try
        {
            STR.fin_CreateNewStructure(txtProg.Value.ToString(),txtSession.Text,int.Parse(txtAcademicYear.Text.Substring(0,4)),int.Parse(txtTerm.Text),
                int.Parse(txtYear.Text),txtBillingSystem.Value.ToString());
            lbl_msg.Text="Structure Created Successfully";
            pop_messagebox.ShowOnPageLoad=true;
        }
        catch (Exception ex)
        {
            lbl_msg.Text="Errror! ["+ex.Message+"]";
            pop_messagebox.ShowOnPageLoad=true;
        }
        gvClass.DataBind();
    }
    protected void txtClass_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvClass.DataBind();
    }
    protected void btn_billitems_Click(object sender, EventArgs e)
    {
        pop_billitems.ContentUrl = "~/COOPERP/Financials/BatchFeesStructure.aspx";
        pop_billitems.Height = 600;
        pop_billitems.Width = 1000;
        Session["yr"] = txtAcademicYear.Text;
        Session["cyr"] = txtYear.Text;
        Session["semester"] = txtTerm.Text;
        Session["sess"] = txtSession.Text;
        Session["amt"] = gvClass.GetRowValues(gvClass.FocusedRowIndex, "amount");
        Session["ItemCode"] = gvClass.GetRowValues(gvClass.FocusedRowIndex, "ItemCode");
        Session["ItemName"] = gvClass.GetRowValues(gvClass.FocusedRowIndex, "ItemName");
        Session["bid"] = txtBillingSystem.Value;
        pop_billitems.ShowOnPageLoad = true;
    }
    protected void btn_billingitems_Click(object sender, EventArgs e)
    {
        Session["progid"] = txtProg.Value;
        Session["studsession"] = txtSession.Text;

        pop_billitems.Height = 600;
        pop_billitems.Width = 800;
        pop_billitems.ContentUrl = "~/COOPERP/financials/billitems.aspx";
        pop_billitems.ShowOnPageLoad = true;
    }
    protected void btn_payschedule_Click(object sender, EventArgs e)
    {
        pop_billitems.ContentUrl = "~/COOPERP/Financials/FeesPaySchedule.aspx";
        pop_billitems.Height = 600;
        pop_billitems.Width = 1000;
        Session["eyr"] = txtAcademicYear.Text;
        Session["prog"] = txtProg.Value;
        Session["sess"] = txtSession.Text;
        Session["bid"] = txtBillingSystem.Value;
        pop_billitems.ShowOnPageLoad = true;
    }
    protected void gvClass_DataBound(object sender, EventArgs e)
    {
        if (gvClass.VisibleRowCount == 0)
        {
            btn_payschedule.Enabled = false;
            cmdAdopt.Enabled = false;
            //cmdPrintStructure.Enabled = false;
            cmdViewAll.Enabled = false;
        }
        else
        {
            btn_payschedule.Enabled = true;
            btn_payschedule.Enabled = true;
            cmdPrintStructure.Enabled = true;
            cmdViewAll.Enabled = true;
            cmdAdopt.Enabled = true;
        }
    }
    protected void cmdAdopt_Click(object sender, EventArgs e)
    {
        pop_adopt.ShowOnPageLoad = true;
    }
    protected void cmdAdoptStructure_Click(object sender, EventArgs e)
    {
        StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter STRU = new StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter();
        string IncludeSchedule="No";
        if(chk_FeesSchedule.Checked) IncludeSchedule="Yes";
        STRU.fin_adoptStructure(txtProg.Value.ToString(), txtSession.Text, txtAcademicYear.Text, txtNewProg.Value.ToString(), 
            txtNewSession.Text, IncludeSchedule,int.Parse(txtNewAcademicYear.Text));
    }
    protected void cmdPrintStructure_Click(object sender, EventArgs e)
    {
        pop_billitems.Width = 900;
        pop_billitems.Height = 600;
        pop_billitems.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        Session["prog"] = txtProg.Value;
        Session["bid"] = txtBillingSystem.Value;
        Session["acad"] = txtAcademicYear.Text;
        Session["Report"] = "FeesStructure";
        pop_billitems.ShowOnPageLoad = true;
    }
}