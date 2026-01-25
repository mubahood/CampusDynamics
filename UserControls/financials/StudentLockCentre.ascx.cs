using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_StudentLockCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }
    }
    protected void gvStudentList_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdCapture_Click(object sender, EventArgs e)
    {
        int noUsers = gvSchoolPayList.VisibleRowCount;
        AdjustmentsCentreTableAdapters.fin_GetStudentAccountsListTableAdapter USER = 
            new AdjustmentsCentreTableAdapters.fin_GetStudentAccountsListTableAdapter();
        for (int i = 0; i < noUsers; i++)
        {
            if (gvSchoolPayList.Selection.IsRowSelected(i))
            {
                USER.UpdateLockStatus(gvSchoolPayList.GetRowValues(i,"id").ToString());
            }
        }
        gvSchoolPayList.DataBind();
    }
    protected void cmdExportData_Click(object sender, EventArgs e)
    {
        GVE_SchoolPay.WriteXlsToResponse(string.Format("StudentUserAccounts"), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    protected void cmdRefresh_Click(object sender, EventArgs e)
    {
        PortalSecurityTableAdapters.fin_studentlocksTableAdapter STUDLOCKS = new PortalSecurityTableAdapters.fin_studentlocksTableAdapter();
        STUDLOCKS.RefreshList();
        gvSchoolPayList.DataBind();
    }
    protected void cmdUpdateStatus_Click(object sender, EventArgs e)
    {
        int noRows = gvSchoolPayList.VisibleRowCount,counter=0;
        PortalSecurityTableAdapters.fin_studentlocksTableAdapter STUDLOCKS = new PortalSecurityTableAdapters.fin_studentlocksTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            if (gvSchoolPayList.Selection.IsRowSelected(i))
            {
                STUDLOCKS.UpdateLockStatus(txt_reason.Text, DateTime.Now, HttpContext.Current.User.Identity.Name,
                    gvSchoolPayList.GetRowValues(i, "regno").ToString());
                counter++;
                lbl_msgbox.Text = counter+" Locks Updated";

            }
        }
        gvSchoolPayList.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
    }
}