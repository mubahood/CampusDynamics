using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using StudentAccountingDataTableAdapters;
using CoopERPDataTableAdapters;
using System.Threading.Tasks;


public partial class UserControls_financials_studentbilling : System.Web.UI.UserControl
{
    fin_GetStudentFeesTrackListTableAdapter Tracker = new fin_GetStudentFeesTrackListTableAdapter();
    string UserName = HttpContext.Current.User.Identity.Name;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcademicYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtAcademicYear.DataBind();
            txtAcademicYear.Text = CommonRoutines.DefaultAcadYear();

            txtTerm.Text = CommonRoutines.DefaultSemester();

            txtStartDate.Date = DateTime.Today.AddDays(-30);
            txtEndDate.Date = DateTime.Today;
        }
        pop_billitems.Width = 1000;
        pop_billitems.Height = 500;

        
       
        
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        int noRows = gvClass.VisibleRowCount, Counter = 0;
        string regno="-", Comm = "Billing Not Completed",residence;
        fin_GetStudentFeesTrackListTableAdapter STUD = new fin_GetStudentFeesTrackListTableAdapter();

        for (int i = 0; i < noRows; i++)
        {
            if (gvClass.Selection.IsRowSelected(i))
            {

                try
                {
                    regno = gvClass.GetRowValues(i, "regno").ToString();
                    residence = gvClass.GetRowValues(i, "residence").ToString();
                    STUD.fin_Autobilling(regno, txtAcademicYear.Text, int.Parse(txtTerm.Text), "REG", HttpContext.Current.User.Identity.Name, "-");
                    if (residence == "RESIDENT")
                    {
                        STUD.fin_Autobilling(regno, txtAcademicYear.Text, int.Parse(txtTerm.Text), "ACCOMO", HttpContext.Current.User.Identity.Name, "-");
                    }
                    Counter++;
                    Comm = Counter + " Students Auto Billed Successfully";
                }
                catch (Exception ex)
                {
                    Comm = "Error! " + ex.Message + " On Reg No: " + regno;
                    break;
                }
            }
        }

            
        gvClass.DataBind();
        lbl_msg.Text = Comm;
        pop_messagebox.ShowOnPageLoad = true;
    }

    

    protected void cmdDisplay_Click(object sender, EventArgs e)
    {
        gvClass.DataBind();
    }

    

    protected void txtClass_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void cmdLedger_Click(object sender, ImageClickEventArgs e)
    {
        pop_billitems.Height = 500;
        pop_billitems.Width = 900;
        pop_billitems.ContentUrl = "~/COOPERP/Financials/StudentLedger.aspx";
        Session["yr"] = txtAcademicYear.Text;
        Session["trm"] = txtTerm.Text;
        Session["residence"] = gvClass.GetRowValues(gvClass.FocusedRowIndex, "residence");
        Session["regno"] = gvClass.GetRowValues(gvClass.FocusedRowIndex, "regno");
        Session["stud_names"] = gvClass.GetRowValues(gvClass.FocusedRowIndex, "stud_names");
        Session["sDate"] = txtStartDate.Date;
        Session["eDate"] = txtEndDate.Date;
        Session["acad"] = txtAcademicYear.Text;
        Session["sems"] = txtTerm.Text;
        pop_billitems.ShowOnPageLoad = true;

    }
    protected void cmdDeleteBill_Click(object sender, EventArgs e)
    {
        int noRows = gvClass.VisibleRowCount, Counter = 0;
        string Admno, Comm = "No Student Selected";
       
        lbl_msg.Text = Comm;
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void cmdPrintList_Click(object sender, EventArgs e)
    {
        pop_billitems.Width = 900;
        pop_billitems.Height = 600;
        pop_billitems.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        Session["acad"] = txtAcademicYear.Text;
        Session["sem"] = txtTerm.Text;
        Session["prog"] = txtProg.Value;
        Session["sess"] = txtSession.Text;
        Session["stat"] = txtStat.Text;
        Session["yr"] = txtYear.Text;
        Session["Report"] = "Fees List";
        Session["sDate"] = txtStartDate.Date;
        Session["eDate"] = txtEndDate.Date;
        pop_billitems.ShowOnPageLoad = true;
    }
    protected void txtBillItems_SelectedIndexChanged(object sender, EventArgs e)
    {
       
    }
    protected void cmdSMS_Click(object sender, EventArgs e)
    {

        /*int noRows = gvClass.VisibleRowCount;
        string prefix;
        SMSSendingBLL sms = new SMSSendingBLL();
        admissions_and_classesTableAdapters.studentTableAdapter stud = new admissions_and_classesTableAdapters.studentTableAdapter();
        string message = "";
        if (txtSMS.Text.Length > 100)
        {
            lbl_msg.Text = "Only 100 Characters are required for the message";
        }
        else
        {
            for (int i = 0; i < noRows; i++)
            {
                if (gvClass.Selection.IsRowSelected(i) == true)
                {
                    if (txtStat.Text.Contains("Pending"))
                    {
                        message = string.Format("Dear Parent, your child {0} of S{2} {3} has a fees balance of {1}. {4}.",
                            gvClass.GetRowValues(i, "stud_names"), gvClass.GetRowValues(i, "curBal"), txtClass.Text, txtStream.Text, txtSMS.Text);
                    }
                    else
                    {
                        message = string.Format("{3} for your child {0} of S{1} {2}.",
                           gvClass.GetRowValues(i, "stud_names"), txtClass.Text, txtStream.Text, txtSMS.Text);
                    }
                    lbl_msg.Text = sms.SMSSending(txtSMSSender.Text,
                        message, stud.GetParentPhone(gvClass.GetRowValues(i, "adm_no").ToString()).ToString());
                }
            }
        }
        pop_messagebox.ShowOnPageLoad = true;*/
    }

    protected void btn_billitems_Click(object sender, EventArgs e)
    {
        int ACYear=int.Parse(txtAcademicYear.Text.Substring(0, 4)),StudyYear=int.Parse(txtYear.Text);
        Session["progid"] = txtProg.Value;
        Session["studsession"] = txtSession.Text;
        Session["DefaultYear"] = ACYear-(StudyYear-1);
        pop_billitems.ContentUrl = "~/COOPERP/financials/billitems.aspx";
        pop_billitems.ShowOnPageLoad = true;
    }
    protected void gvClass_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdPostBilling_Click(object sender, EventArgs e)
    {
        int noRows = gvClass.VisibleRowCount, Counter = 0;
        string regno = "-", Comm = "Billing Not Completed";
        lbl_single_bill_comm.Text = "";
        AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter STUD = new AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            if (gvClass.Selection.IsRowSelected(i) && txtAmount.Text!="0")
            {

                try
                {
                    regno = gvClass.GetRowValues(i, "regno").ToString();
                    STUD.fin_SingleBilling(regno, txtAcademicYear.Text, int.Parse(txtTerm.Text),HttpContext.Current.User.Identity.Name,
                        int.Parse(txtSingleItem.Value.ToString()),double.Parse(txtAmount.Text));
                    Counter++;
                    Comm = Counter + " Students Billed Successfully";
                }
                catch (Exception ex)
                {
                    Comm = "Error! " + ex.Message + " On Reg No: " + regno;
                    break;
                }
            }
        }
        gvClass.DataBind();
        lbl_single_bill_comm.Text = Comm;
    }
    protected void gvClass_DataBound(object sender, EventArgs e)
    {
        if (gvClass.VisibleRowCount == 0)
        {
            cmdSingleItem.Enabled = false;
            cmdNew.Enabled = false;
            cmdBillingCorrection.Enabled = false;
        }
        else
        {
            cmdSingleItem.Enabled = true;
            cmdNew.Enabled = true;
            cmdBillingCorrection.Enabled = true;
        }
    }
    protected void cmdBillingCorrection_Click(object sender, EventArgs e)
    {
        AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter ADJ = new AdjustmentsCentreTableAdapters.fin_ledgerTableAdapter();
        int noRows = gvClass.VisibleRowCount, Counter = 0;
        string regno = "-", Comm = "Billing Not Completed", residence;
        fin_GetStudentFeesTrackListTableAdapter STUD = new fin_GetStudentFeesTrackListTableAdapter();

        for (int i = 0; i < noRows; i++)
        {
            if (gvClass.Selection.IsRowSelected(i))
            {

                try
                {
                    regno = gvClass.GetRowValues(i, "regno").ToString();
                    residence = gvClass.GetRowValues(i, "residence").ToString();
                    ADJ.fin_CorrectionBilling(regno, txtAcademicYear.Text, int.Parse(txtTerm.Text), "REG",
                    HttpContext.Current.User.Identity.Name, residence);
                    Counter++;
                    Comm = Counter + " Students Billed Successfully";
                }
                catch (Exception ex)
                {
                    Comm = "Error! " + ex.Message + " On Reg No: " + regno;
                    break;
                }
            }
        }
        gvClass.DataBind();
        lbl_msg.Text = Comm;
        pop_messagebox.ShowOnPageLoad = true;

    }
}