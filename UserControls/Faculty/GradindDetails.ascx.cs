using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Faculty_GradindDetails : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_DetailsMsg.HeaderText = SettingsFile.AppName;
        rp_details.HeaderText = Session["HeaderText"].ToString();
    }
  

    protected void CBP_Marks_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        ResultsDataTableAdapters.acad_gs_detailsTableAdapter GSD = new ResultsDataTableAdapters.acad_gs_detailsTableAdapter();
        GSD.Insert(uint.Parse(Session["gsid"].ToString()), "-", 0, 0, 0);
        lbl_comment.Text = "Blank Grading Added. Edit and Fine tune Please";
    }
    protected void CBP_Award_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        ResultsDataTableAdapters.acad_gs_awardTableAdapter AWARD = new ResultsDataTableAdapters.acad_gs_awardTableAdapter();
        AWARD.Insert(uint.Parse(Session["gsid"].ToString()), 0, 0, "-", txtLevel.Text);
        lbl_AwardComment.Text = "Blank Grading Added. Edit and Fine tune Please";
    }
}