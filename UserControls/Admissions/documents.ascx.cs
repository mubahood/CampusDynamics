using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Data.PivotGrid;


public partial class UserControls_Admissions_documents : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_print.Width = 800;
        pop_print.Height = 500;
        if (!IsPostBack)
        {
            txtProg.Value = "-";
            txtEntryYear.DataSource = CommonRoutines.ReturnYears();
            txtEntryYear.DataBind();
            txtEntryYear.Text = DateTime.Today.Year.ToString();

            txt_currentyear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txt_currentyear.DataBind();
            txt_currentyear.Text = string.Format("{0}/{1}", DateTime.Today.Year, DateTime.Today.Year + 1);

            txt_startyear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txt_startyear.DataBind();
            txt_startyear.Text = string.Format("{0}/{1}", DateTime.Today.Year - 3, DateTime.Today.Year - 2);

            txt_EndYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txt_EndYear.DataBind();
            txt_EndYear.Text = string.Format("{0}/{1}", DateTime.Today.Year, DateTime.Today.Year + 1);

           // txtCampus.Value = "02";
            pvt_admissions.DataBind();
        }

        pvt_admissions.Fields.GetFieldByName("fieldstudents1").SummaryDisplayType = DisplayFormat();
    }
    protected void btn_print_Click(object sender, EventArgs e)
    {

        Session["Report"] = txt_document.Value ;
        Session["entyear"] = txtEntryYear.Text;
        Session["programme"] = txtProg.Value;
        Session["Sess"] = txt_session.Value;
        Session["intake"] = txtIntake.Value;
        Session["campus"] = txt_campus.Value;
        Session["Letter"] = txt_letter.Text;
        pop_print.ShowOnPageLoad = true;
    }


    protected void btn_export_Click(object sender, EventArgs e)
    {
        if (txt_export.Value == "PDF")
        {
            exp_admissions.ExportPdfToResponse("AdmissionStats", true);
        }
        else if (txt_export.Value == "RTF")
        {
            exp_admissions.ExportRtfToResponse("AdmissionStats", true);
        }
        else
        {
            exp_admissions.ExportXlsToResponse("AdmissionStats", true);
        }
    }
    protected void txt_analysistype_SelectedIndexChanged(object sender, EventArgs e)
    {
        pvt_admissions.DataBind();
        chart_admissions.DataBind();
    }

    protected void txt_format_SelectedIndexChanged(object sender, EventArgs e)
    {
        pvt_admissions.Fields.GetFieldByName("fieldstudents1").SummaryDisplayType = DisplayFormat();
    }

    PivotSummaryDisplayType DisplayFormat()
    {
        if (txt_format.Value == "numeric")
        {
            return PivotSummaryDisplayType.Default;
        }
        else if (txt_format.Value == "colpercent")
        {
            return PivotSummaryDisplayType.PercentOfColumn;
        }
        else
        {
            return PivotSummaryDisplayType.PercentOfRow;
        }
    }

    protected void pvt_admissions_DataBinding(object sender, EventArgs e)
    {
        chart_admissions.DataBind();
    }
}