using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Results_GraduationAnalysis : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            txtPrintGradDate.Date = DateTime.Today;
        }
        cmdExport.Text = "Export to " + cbx_Exportformat.Text;
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        if (cbx_Exportformat.Text == "Excel")
        {
            GE_UsageStats.ExportXlsToResponse("GraduationAnalysis", true);
        }
        else
            GE_UsageStats.ExportPdfToResponse("GraduationAnalysis", true);  
    }
}