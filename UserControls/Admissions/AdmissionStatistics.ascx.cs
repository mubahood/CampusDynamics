using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Data.PivotGrid;

public partial class UserControls_Admissions_AdmissionStatistics : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = string.Format("{0}/{1}", DateTime.Today.Year, DateTime.Today.Year + 1);

            txtStartYear.DataSource = CommonRoutines.ReturnYears();
            txtEndYear.DataSource = CommonRoutines.ReturnYears();
txtStartYear.Text = DateTime.Today.AddYears(-3).Year.ToString();
            txtEndYear.Text = DateTime.Today.Year.ToString();
            txtStartYear.DataBind();
            txtEndYear.DataBind();

            txtCampus.Value = "01";
            admission_data ds = new admission_data();
            ds.EnforceConstraints = false;
            pvt_AdmnStatistics.DataBind();
        }

        pvt_AdmnStatistics.Fields.GetFieldByName("fieldstudents1").SummaryDisplayType = DisplayFormat();

    }
    protected void cbk_admstats_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        if (e.Parameter == "PercentageType")
        {
            pvt_AdmnStatistics.Fields.GetFieldByName("fieldstudents1").SummaryDisplayType = DisplayFormat();
        }
        else if (e.Parameter == "Export")
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
    
    PivotSummaryDisplayType DisplayFormat()
    {
        if (txtPercentage.Value == "numeric")
        {
            return PivotSummaryDisplayType.Default;
        }
        else if (txtPercentage.Value == "colpercent")
        {
            return PivotSummaryDisplayType.PercentOfColumn;
        }
        else
        {
            return PivotSummaryDisplayType.PercentOfRow;
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
}