using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HRMDataTableAdapters;
using InternationalDataTableAdapters;

public partial class UserControls_HumanResource_TeacherMgt_AcademicStaffDetails : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["Cat"].ToString() == "Tutorship")
        {
            page_allocations.TabPages[0].Enabled = false;
            page_allocations.ActiveTabIndex = 1;
        }
        else
        {
            page_allocations.TabPages[1].Enabled = false;
            page_allocations.ActiveTabIndex = 0;
        }
        //txtyr.DataSource = CommonRoutines.ReturnYears();
        //txt_tutoryear.DataSource = CommonRoutines.ReturnYears();
        //txtyr.DataBind();
        //txt_tutoryear.DataBind();
   
        if (!IsPostBack)
        {
            txtyr.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtyr.DataBind();
            txtyr.Text = CommonRoutines.ReturnDefaultAcademicYrs();

            txt_tutoryear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txt_tutoryear.DataBind();
            txt_tutoryear.Text = CommonRoutines.ReturnDefaultAcademicYrs();

            txt_tutorterm.Text = CalendaManager.DefaultTerm();
            txtterm.Text = CalendaManager.DefaultTerm();

            Session["class"] = txtClass.Text;
            Session["year"] = txtyr.Text;
            Session["term"] = txtterm.Text;
            Session["tutoryear"] = txt_tutoryear.Text;
            Session["tutorterm"] = txt_tutorterm.Text;
            lblheader.Text = ("SUBJECT ALLOCATION FOR " + Session["EmpName"].ToString() +  " " + "TERM" + " " + Session["term"] + ", " + Session["year"]).ToUpper();
            lbl_tutorgroupheader.Text = ("GROUP ALLOCATION FOR " + Session["EmpName"].ToString() + " " + "TERM" + " " + Session["tutorterm"] + ", " + Session["tutoryear"]).ToUpper();
            gvAllocations.DataBind();
            gvtutorgroup.DataBind();
        }
        

        int Class = int.Parse(txtClass.Value.ToString());
        if (Class < 10)
        {
            Session["Level"] = "LS";

        }
        else if (Class < 12)
        {
            Session["Level"] = "IGCSE";
            // txtPaper.Text = "1";
        }
        else
        {
            Session["Level"] = "CIE";
        }
    }
    protected void txtClass_SelectedIndexChanged(object sender, EventArgs e)
    {
        Session["class"] = txtClass.Text;
        Session["year"] = txtyr.Text;
        Session["term"] = txtterm.Text;
        txtsubject.DataBind();
        lblheader.Text = "SUBJECT ALLOCATION FOR " + Session["EmpName"].ToString() +  " " + "TERM" + " " + Session["term"] + ", " + Session["year"];
        gvAllocations.DataBind();
    }
    protected void btnallocate_Click(object sender, EventArgs e)
    {
        try
        {
            int_subjectallocationTableAdapter allocation = new int_subjectallocationTableAdapter();
            allocation.Insert(txtyr.Text, Convert.ToUInt32(txtterm.Text), Convert.ToUInt32(txtClass.Value), txtsubject.Value.ToString(), 
                Session["EmpNo"].ToString(), Convert.ToUInt32(txtpaper.Text),"",100,100,"-");
            gvAllocations.DataBind();
        }
        catch (Exception ex)
        {
            lbl_message.Text = "Error : " + ex.Message;
            popup_message.ShowOnPageLoad = true;
        }

    }
    protected void txt_tutoryear_SelectedIndexChanged(object sender, EventArgs e)
    {
        //Session["tutorclass"] = txt_studentclass.Text;
        Session["tutoryear"] = txt_tutoryear.Text;
        Session["tutorterm"] = txt_tutorterm.Text;
        lbl_tutorgroupheader.Text = "GROUP ALLOCATION FOR " + Session["EmpName"].ToString() + " " + "TERM" + " " + Session["tutorterm"] + ", " + Session["tutoryear"];
        gvtutorgroup.DataBind();
    }
    protected void btnAddStudent_Click(object sender, EventArgs e)
    {
        try
        {
            int_classmanagerTableAdapter CLS = new int_classmanagerTableAdapter();
            int_tutorgroupsTableAdapter student = new int_tutorgroupsTableAdapter();
            student.Insert(uint.Parse(CLS.GetMyClass(txtAdmNo.Text,txt_tutoryear.Text,int.Parse(txt_tutorterm.Text)).ToString()), txt_tutoryear.Text, 
                Convert.ToUInt32(txt_tutorterm.Text), txtAdmNo.Text, Convert.ToUInt32(Session["EmpNo"].ToString()),"","");
            gvtutorgroup.DataBind();
        }
        catch (Exception ex)
        {
            lbl_tutormessage.Text = "Error : " + ex.Message;
            popup_tutorgroups.ShowOnPageLoad = true;
        } 
    }
    protected void gvAllocations_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {

    }
}