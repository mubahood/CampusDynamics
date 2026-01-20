using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Net;


public partial class UserControls_financials_feespaymenttracking : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
     if (!IsPostBack)
        {
            txtYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtYear.DataBind();
            txtYear.Text = calendaEventsBLL.DefaultAcadYear();
            txtTerm.Text = StudentBillsPaymentBLL.DefaultTerm();
        }

        Session["ReportType"] = "FeesList";
        Session["year"] = txtYear.Text;
        Session["stream"] = txtStream.Text;
        Session["cls"] = txtClass.Text;
        Session["term"] = txtTerm.Text;
        Session["BalStat"] = txtStatus.Value;

        pop_print.Width = 900;
        pop_print.Height = 600;

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
    protected void cmdViewLists_Click(object sender, EventArgs e)
    {
        gvFeesLists.DataBind();
    }

    protected void cmdSMS_Click(object sender, EventArgs e)
    {
        int noRows = gvFeesLists.VisibleRowCount;
        SMSSendingBLL sms = new SMSSendingBLL();
        admissions_and_classesTableAdapters.studentTableAdapter stud = new admissions_and_classesTableAdapters.studentTableAdapter();
        string message = "";
        for (int i = 0; i < noRows; i++)
        {
            if (gvFeesLists.Selection.IsRowSelected(i) == true)
            {
                if (txtStatus.Text.Contains("Incomplete"))
                {
                    message = string.Format("Dear Parent, your child {0} of S{2} {3} has a fees balance of {1}. {4}.",
                        gvFeesLists.GetRowValues(i, "studentName"), gvFeesLists.GetRowValues(i, "CurrentBalance"), txtClass.Text, txtStream.Text, txtSMS.Text);
                }
                else
                {
                    message = string.Format("{3} for your child {0} of S{1} {2}.",
                       gvFeesLists.GetRowValues(i, "stud_names"), txtClass.Text, txtStream.Text, txtSMS.Text);
                }

                lbl_comments.Text = sms.SMSSending("KakunguluMS", message, stud.GetParentPhone(gvFeesLists.GetRowValues(i, "adm_no").ToString()).ToString());
            }
        }
    }
    protected void txtStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (txtStatus.Text.Contains("Incomplete"))
        {
            txtSMS.Text = "Please Come with the balance";
        }
        else
        {
            txtSMS.Text = "Thanks for timely fees payment";
        }
    }
}