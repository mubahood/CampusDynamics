using System;
using System.Web.UI;

public partial class COOPERP_NewScreens_NewFaculties : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        // Show the DevExpress edit form for new row
        gvMain.AddNewRow();
    }

    protected void gvMain_RowCommand(object sender, DevExpress.Web.ASPxGridViewRowCommandEventArgs e)
    {
        
    }
}
