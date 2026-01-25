using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using admission_dataTableAdapters;

public partial class UserControls_Admissions_letters : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
        txt_entyr.DataSource= CommonRoutines.ReturnAcademicYrs();
        txt_entyr.DataBind();
        if (!IsPostBack)
        {
            txt_entyr.Text = string.Format("{0}/{1}", DateTime.Today.Year, DateTime.Today.Year + 1);
            gv_letters.DataBind();
        }

    }
    protected void btn_newletter_Click(object sender, EventArgs e)
    {
        gv_letters.AddNewRow();
    }
    protected void txt_entyr_SelectedIndexChanged(object sender, EventArgs e)
    {
        gv_letters.DataBind();
    }
    protected void gv_letters_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["acadyear"] = txt_entyr.Text;
    }
    protected void gv_letters_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void btn_adoptletter_Click(object sender, EventArgs e)
    {
        try
        {
            acad_admissionlettersTableAdapter lett = new acad_admissionlettersTableAdapter();
            lett.acad_AdoptAdmissionLetters(txt_entyr.Text);
            gv_letters.DataBind();
            lbl_msg.Text = "Templates Created Successfully.";
            pop_message.ShowOnPageLoad = true;

        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error: " + ex.Message;
            pop_message.ShowOnPageLoad = true;
        }
    }
}