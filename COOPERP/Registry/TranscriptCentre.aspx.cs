using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Registry_TranscriptCentre : System.Web.UI.Page
{
    protected override object LoadPageStateFromPersistenceMedium()
    {
        try
        {
            return base.LoadPageStateFromPersistenceMedium();
        }
        catch
        {
            return null;
        }
    }

    protected override void LoadViewState(object savedState)
    {
        try
        {
            base.LoadViewState(savedState);
        }
        catch
        {
            base.LoadViewState(null);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }
}