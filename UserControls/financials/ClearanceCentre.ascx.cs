using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_ClearanceCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();

            pop_msgbox.Width = 300;
            pop_msgbox.Height = 150;

            txtEntryYear.DataSource = SettingsFile.ReturnYears();
            txtEntryYear.DataBind();
            txtEntryYear.Text = DateTime.Today.Year.ToString();
        }

        if (txtStatus.Text == "Cleared") cmdIndicatePrinted.Enabled = true; else cmdIndicatePrinted.Enabled = false;
        if (!HttpContext.Current.User.IsInRole("Bursar") && !HttpContext.Current.User.IsInRole("Exam Clearance"))
        {
            cmdClear.Enabled = false;
            cmdManualClearance.Enabled = false;
        }
    }
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        pop_msgbox.ContentUrl = "";
        try
        {
            StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter CLR = new StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter();
            CLR.fin_AutoProcessClearances(txtAcadYear.Text, int.Parse(txtSemester.Text), txtClearanceType.Value.ToString(), txtStatus.Text, HttpContext.Current.User.Identity.Name);
            lbl_msgbox.Text = "Auto Clearance Processing Completed";
            gvLedger.DataBind();
        }
        catch (Exception ex) { lbl_msgbox.Text = "An Error Occured [" + ex.Message + "]"; }

        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdRevoke_Click(object sender, EventArgs e)
    {
        int noRows = gvLedger.VisibleRowCount, counter = 0;
        string comm = "No Students Selected";
        StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter CLR = new StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter();
        if (HttpContext.Current.User.IsInRole("Bursar") || HttpContext.Current.User.IsInRole("Exam Clearance"))
        {
            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    CLR.fin_RevokeClearance(txtClearanceType.Value.ToString(), gvLedger.GetRowValues(i, "regno").ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text),
                        HttpContext.Current.User.Identity.Name);
                    counter++;
                    comm = counter + " Student(s) " + txtClearanceType.Value + " Clearances Revoved";
                }
            }
        }
        else
        {
            comm = "Sorry. Only Bursar Handles Manual Clearances!";
        }
        gvLedger.DataBind();
        lbl_msgbox.Text = comm;

        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdManualClearance_Click(object sender, EventArgs e)
    {

        int noRows = gvLedger.VisibleRowCount, counter = 0;
        string comm = "No Students Selected";
        StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter CLR = new StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter();
        if (HttpContext.Current.User.IsInRole("Bursar") || HttpContext.Current.User.IsInRole("Exam Clearance"))
        {
            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    CLR.fin_ManualClearance(txtClearanceType.Value.ToString(), gvLedger.GetRowValues(i, "regno").ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text),
                        HttpContext.Current.User.Identity.Name);
                    counter++;
                    comm = counter + " Student(s) " + txtClearanceType.Value + " Processed";

                }
            }
        }
        else
        {
            comm = "Sorry. Only Bursar Handles Manual Clearances!";
        }
        gvLedger.DataBind();
        lbl_msgbox.Text = comm;

        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdPrintCards_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 600;
        Session["Report"] = "Batch Exam Card";
        Session["acad"] = txtAcadYear.Text;
        Session["sem"] = txtSemester.Text;
        Session["prog"] = txtProgramme.Value;
        Session["typ"] = txtCardType.Value;
        pop_msgbox.ContentUrl = ("~/COOPERP/XtraReports/Default.aspx");
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdIndicatePrinted_Click(object sender, EventArgs e)
    {
        int noRows = gvLedger.VisibleRowCount, counter = 0;
        string comm = "No Students Selected";
        StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter CLR = new StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter();
        
            for (int i = 0; i < noRows; i++)
            {
                if (gvLedger.Selection.IsRowSelected(i))
                {
                    CLR.fin_ManualClearance(txtClearanceType.Value.ToString(), gvLedger.GetRowValues(i, "regno").ToString(), txtAcadYear.Text, int.Parse(txtSemester.Text),
                        HttpContext.Current.User.Identity.Name);
                    counter++;
                    comm = counter + " Student(s) " + txtClearanceType.Value + " Processed";

                }
            }
        
        gvLedger.DataBind();
        lbl_msgbox.Text = comm;

        pop_msgbox.ContentUrl = "";
        pop_msgbox.Width = 300;
        pop_msgbox.Height = 150;
        pop_msgbox.ShowOnPageLoad = true;
    }
    protected void cmdExportToExcel_Click(object sender, EventArgs e)
    {
        GVE_SchoolPay.WriteXlsToResponse(string.Format("{1}_ClearanceListData_{0}_Sem_{3}_{2}",DateTime.Today.ToString("dd MMM, yyyy"),txtStatus.Text,
            txtAcadYear.Text,txtSemester.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });

    }
}