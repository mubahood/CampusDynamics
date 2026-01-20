using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_LegacyStudents : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = CommonRoutines.ReturnYears();
            txtAcadYear.DataBind();
            txtAcadYear.Text = (DateTime.Today.Year - 1).ToString();
        }
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        GVE_Marksheets.WriteXlsToResponse(string.Format("{2} LegacyGraduands {0}", txtAcadYear.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });

    }
    protected void cmdTranscript_Click(object sender, ImageClickEventArgs e)
    {
        Session["Report"] = "Legacy Transcript";
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_details.Width = 800;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/Results/Reports/PrintCentre.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdCertificate_Click(object sender, ImageClickEventArgs e)
    {
        Session["Report"] = "Legacy Certificate";
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_details.Width = 800;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvMarksheetInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void gvMarksheetInfo_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        //e.NewValues["phone"] = "-";
    }
    protected void cmdAttachPhoto_Click(object sender, EventArgs e)
    {
        pop_msgBox.Width = 800;
        pop_msgBox.Height = 250;
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_msgBox.ContentUrl = "~/COOPERP/Registry/PhotoUpload.aspx";
        pop_msgBox.ShowOnPageLoad = true;
    }
    protected void cmdResults_Click(object sender, EventArgs e)
    {
        pop_msgBox.Width = 1000;
        pop_msgBox.Height = 550;
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_msgBox.ContentUrl = "~/COOPERP/Registry/LegacyResults.aspx";
        pop_msgBox.ShowOnPageLoad = true;
    }
}