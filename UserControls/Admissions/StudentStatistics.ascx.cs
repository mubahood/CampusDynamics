using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Data.PivotGrid;
using DevExpress.XtraPrinting;

public partial class UserControls_Admissions_AdmissionStatistics : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = string.Format("{0}/{1}", DateTime.Today.Year, DateTime.Today.Year + 1);

            admission_data ds = new admission_data();
            ds.EnforceConstraints = false;
            pvt_AdmnStatistics.DataBind();
        }
        if (txtListBy.Text != "Semester")
        {
            txtSemester.Enabled = false;
        }
        else
        {
            txtSemester.Enabled = true;
        }

    }
    protected void cbk_admstats_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        if (e.Parameter == "Export")
        {
            if (txtExportFormat.Value == "PDF")
        {
            GE_AdmnStats.ExportPdfToResponse("AdmnStats", true);
        }
        else if (txtExportFormat.Value == "RTF")
        {
            GE_AdmnStats.ExportRtfToResponse("AdmnStats", true);
        }
        else
        {
            GE_AdmnStats.ExportXlsToResponse("AdmnStats", true);
        }
    }
        }
    
   
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (txtExportFormat.Value == "PDF")
        {
            GE_AdmnStats.ExportPdfToResponse("AdmnStats", true);
        }
        else if (txtExportFormat.Value == "RTF")
        {
            GE_AdmnStats.ExportRtfToResponse("AdmnStats", true);
        }
        else
        {
            GE_AdmnStats.ExportXlsToResponse("AdmnStats", true);
        }
    }
    protected void gvCRRate_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void btnExportList_Click(object sender, EventArgs e)
    {
        gve_studlist.WriteXlsxToResponse("StudentListing_"+txtAcadYear.Text+"SEM "+txtSemester.Text, new XlsxExportOptions { ExportMode = XlsxExportMode.SingleFile });
    }
    protected void btnExport_Click1(object sender, EventArgs e)
    {
        if (txtExportFormat.Value == "PDF")
        {
            GE_AdmnStats.ExportPdfToResponse("AdmnStats", true);
        }
        else if (txtExportFormat.Value == "RTF")
        {
            GE_AdmnStats.ExportRtfToResponse("AdmnStats", true);
        }
        else
        {
            GE_AdmnStats.ExportXlsToResponse("AdmnStats", true);
        }
    }
}