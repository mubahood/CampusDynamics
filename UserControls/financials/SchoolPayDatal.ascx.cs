using DevExpress.XtraPrinting;
using StudentAccountingDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_SchoolPayDatal : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Date = DateTime.Today.AddDays(-7);
            txtEndDate.Date = DateTime.Today;
        }
    }
    protected void gvStudentList_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdCapture_Click(object sender, EventArgs e)
    {
        int noRows = gvSchoolPayList.VisibleRowCount,counter=0;
        for (int i = 0; i < noRows; i++)
        {
            if (gvSchoolPayList.Selection.IsRowSelected(i))
            {
                string comm = "", bankChannel = "", tracker = "", smscomm = "", pay_source;
                string tid = gvSchoolPayList.GetRowValues(i, "ReceiptNo").ToString();
                string stud_name = gvSchoolPayList.GetRowValues(i, "stud_name").ToString();
                string regno = gvSchoolPayList.GetRowValues(i, "regno").ToString();
                DateTime TDate = DateTime.Parse(gvSchoolPayList.GetRowValues(i, "datePaid").ToString());
                long amount_paid = long.Parse(gvSchoolPayList.GetRowValues(i, "amount_paid").ToString());
                pay_source = gvSchoolPayList.GetRowValues(i, "channelPaid").ToString();
                SMSSendingBLL MESSAGE = new SMSSendingBLL();
                fin_schoolpaydataTableAdapter SCHPAY = new fin_schoolpaydataTableAdapter();
                AdjustmentsCentreTableAdapters.fin_GetStudentAccountsListTableAdapter STUD = new AdjustmentsCentreTableAdapters.fin_GetStudentAccountsListTableAdapter();
                try
                {
                    bankChannel = pay_source;
                    if (bankChannel.Contains("Shared")) bankChannel = "Bank of Africa";
                    tracker =tid.ToString();
                    string Channel = "SCHOOLPAY";
                    SCHPAY.fin_AutoPayCapture(regno, string.Format("{0} [{1}] - " + Channel, stud_name, regno), BankRouter(pay_source),
                        (amount_paid - 0), TDate, "autocapture",
                        bankChannel, int.Parse(tid));
                    SCHPAY.UpdateCaptureStatus("Captured", long.Parse(tid));
                    try
                    {
                        smscomm = MESSAGE.SMSSending("YCI Accounts Dept", string.Format("{0}, YMCA Institute has received your payment of UGX {1}, Thanks", stud_name, amount_paid.ToString("0,0")),
                            STUD.GetStudPhone(regno).ToString());
                    }
                    catch (Exception ex)
                    {
                        smscomm = "SMSError [" + ex.Message + "]";
                    }
                   lbl_msgbox.Text= "Data Capture Complete";
                }
                catch (Exception ex)
                {
                    lbl_msgbox.Text="Data Capture Error! [" + ex.Message + "]";
                }
            }

        }
        gvSchoolPayList.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
    }
    private String BankRouter(string paySource)
    {
        if (paySource.Contains("Centenary"))
        {
            return "110/007";
        }
        else if (paySource.Contains("Stanbic"))
        {
            return "110/001";
        }

        else if (paySource.Contains("Eco"))
        {
            return "110/008";
        }
        else if (paySource.Contains("Housing"))
        {
            return "110/006";
        }
        else
        {
            return "110/011";
        }
    }
    protected void cmdExportData_Click(object sender, EventArgs e)
    {
        GVE_SchoolPay.WriteXlsToResponse(string.Format("SchoolPayData_{0}_{1}_{2}", txtStartDate.Date.ToString("dd-MM-yyyy"),txtEndDate.Date.ToString("dd-MM-yyyy"), txtStatus.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    public string CaptureTransaction(string regno, string stud_name,long amount,string recno, DateTime TDate,string tid)
    {
        try
        {
            fin_schoolpaydataTableAdapter SCHPAY = new fin_schoolpaydataTableAdapter();
            string Channel = "SCHOOLPAY";
            SCHPAY.fin_AutoPayCapture(regno, string.Format("{0} [{1}] - " + Channel, stud_name, regno), "IU1427", (amount - 0), TDate, "autocapture",
                "DFCU BANK", int.Parse(tid));
            SCHPAY.UpdateCaptureStatus("Captured", long.Parse(tid));
            return "Data Capture Complete";
        }
        catch (Exception ex)
        {
            return "Data Capture Error! [" + ex.Message + "]";
        }
    }
}