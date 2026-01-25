using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Admissions_ApplicantDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lblheader.Text = headercreator();
    }
    public string headercreator()
    {
        return string.Format("DETAILS FOR {0} [{1}]", Session["applic_name"].ToString().ToUpper(), Session["formNo"]);
    }
    protected void gv_Choices_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void gv_Choices_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.Length > 0)
        {
       
         e.ErrorText = UnwrapExceptionMessage(e.Exception);
        }

    }
    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }


    protected void cmdView_Click(object sender, EventArgs e)
    {
        try
        {
            pop_doc_viewer.Width = 600;
            pop_doc_viewer.Height = 500;
            string doc_link = gvDocuments.GetRowValues(gvDocuments.FocusedRowIndex, "doc_path").ToString();
            pop_doc_viewer.HeaderText = gvDocuments.GetRowValues(gvDocuments.FocusedRowIndex, "doc_name").ToString()+" Loading...";
            pop_doc_viewer.ContentUrl = doc_link;
        }
        catch (Exception ex)
        {
            pop_doc_viewer.Width = 350;
            pop_doc_viewer.Height = 200;
            pop_doc_viewer.HeaderText = "File Error! ["+ex.Message+"]";
        }
        pop_doc_viewer.ShowOnPageLoad = true;
    }
}