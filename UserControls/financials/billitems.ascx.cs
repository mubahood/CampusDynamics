using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_billitems : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
   
    protected void gvBillItems_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvBillingItems.AddNewRow();
    }
    protected void cmdCreateFeesList_Click(object sender, EventArgs e)
    {
       
    }

    protected void cmdAddItems_Click(object sender, EventArgs e)
    {
    }
    protected void cmdAddNewItem_Click(object sender, EventArgs e)
    {
        
    }

    protected void gvFeesPaySchedule_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
}