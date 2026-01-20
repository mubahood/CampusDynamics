using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Teaching_Centre_tutorcomments : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

         if (!IsPostBack)
         {

             txt_tutoryear.DataSource = CommonRoutines.ReturnAcademicYrs();
             txt_tutoryear.DataBind();
             txt_tutoryear.Text = CommonRoutines.ReturnDefaultAcademicYrs();
             txtTerm.Text = CalendaManager.DefaultTerm();
             gvtutorgroup.DataBind();
         }

    }
    protected void txt_tutoryear_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvtutorgroup.DataBind();
    }
    protected void cmdResults_Click(object sender, ImageClickEventArgs e)
    {
        int studyclass = int.Parse(gvtutorgroup.GetRowValues(gvtutorgroup.FocusedRowIndex, "studentClass").ToString().Substring(5, 1));
        if (studyclass < 10) Session["level"] = "Lower Secondary"; else if (studyclass == 11) Session["level"] = "IGCSE"; else Session["level"] = "A Level"; ;
        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["admno"] = gvtutorgroup.GetRowValues(gvtutorgroup.FocusedRowIndex, "admno");
        Session["trm"] = txtTerm.Text;
        Session["yr"] = txt_tutoryear.Text;
        Session["cls"] = gvtutorgroup.GetRowValues(gvtutorgroup.FocusedRowIndex, "studentClass").ToString().Substring(5, 1);
        Session["header"] = string.Format("RESULTS FOR {1} [{0}]", Session["admno"], gvtutorgroup.GetRowValues(gvtutorgroup.FocusedRowIndex, "stud_names"));
        pop_details.ContentUrl = "~/COOPERP/ClassManagement/SingleResultsDetails.aspx";
        pop_details.ShowOnPageLoad = true;
    }
}