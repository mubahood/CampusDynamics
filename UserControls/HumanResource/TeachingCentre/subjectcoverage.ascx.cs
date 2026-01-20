using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_TeachingCentre_subjectcoverage : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtyr.DataSource = CommonRoutines.ReturnYears();
        txtyr.DataBind();

        if (!IsPostBack)
        {
            txtyr.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtyr.DataBind();
            txtyr.Text = CommonRoutines.ReturnDefaultAcademicYrs();
            txtTerm.Text = CalendaManager.DefaultTerm();
            gvAllocations.DataBind();
        }

    }
    protected void txtClass_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvAllocations.DataBind();
    }
}