using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_scholarships : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Page_PreInit(object sender, EventArgs e)
    {
        HttpCookie cookie = Request.Cookies.Get("themeCookie");
        if (cookie == null)
        {
            Page.Theme = "Glass"; //default theme
        }
        else
        {
            Page.Theme = cookie.Value;
        }
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        gvScholarships.AddNewRow();
    }
    protected void gvScholarships_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}