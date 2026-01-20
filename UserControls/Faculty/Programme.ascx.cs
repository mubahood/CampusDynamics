using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using FacultyDataTableAdapters;

public partial class UserControls_Faculty_Programme : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvProgrammeInfo.AddNewRow();
    }
    protected void gvProgrammeInfo_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        //acad_programmeTableAdapter PROG = new acad_programmeTableAdapter();
        //e.NewValues["progcode"] = PROG.ProgCodeGenerator(e.NewValues["faculty_code"].ToString(), int.Parse(e.NewValues["levelCode"].ToString()));
    }
    protected void gvProgrammeInfo_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
       // acad_programmeTableAdapter PROG = new acad_programmeTableAdapter();
       // e.NewValues["progcode"] = PROG.ProgCodeGenerator(e.NewValues["faculty_code"].ToString(), int.Parse(e.NewValues["levelCode"].ToString()));
    }
    protected void cmdStructure_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Width = 900;
        pop_details.Height = 550;
        pop_details.ContentUrl = "~/COOPERP/Faculty/ProgrammeStructure.aspx";
        Session["prog"] = gvProgrammeInfo.GetRowValues(gvProgrammeInfo.FocusedRowIndex, "progcode");
        Session["progname"] = gvProgrammeInfo.GetRowValues(gvProgrammeInfo.FocusedRowIndex, "progname");
        pop_details.HeaderText = "COURSE STRUCTURE AND SCORE RATIOS FOR " + Session["progname"] + " [" + Session["prog"] + "]";
        pop_details.ShowOnPageLoad = true;

    }
}