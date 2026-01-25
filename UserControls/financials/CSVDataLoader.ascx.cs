using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_CSVDataLoader : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdSearch_Click(object sender, EventArgs e)
    {
        Random RAND = new Random();
        string fileName = RAND.Next(10000, 99999).ToString() + ".csv";
        string csvPath = Server.MapPath("~/Files/") + Path.GetFileName(FileUpload1.PostedFile.FileName);
        FileUpload1.SaveAs(csvPath);

        //Create a DataTable.
        DataTable dt = new DataTable();
        dt.Columns.AddRange(new DataColumn[4] { 
        new DataColumn("SNO", typeof(int)),
        new DataColumn("RegistrationNo", typeof(string)),
        new DataColumn("Names",typeof(string)),
        new DataColumn("Balance",typeof(double))});

        //Read the contents of CSV file.
        string csvData = File.ReadAllText(csvPath);

        //Execute a loop over the rows.
        foreach (string row in csvData.Split('\n'))
        {
            if (!string.IsNullOrEmpty(row))
            {
                dt.Rows.Add();
                int i = 0;

                //Execute a loop over the columns.
                foreach (string cell in row.Split(','))
                {
                    try
                    {
                        dt.Rows[dt.Rows.Count - 1][i] = cell;
                        i++;
                    }
                    catch (Exception) { }
                }
            }
        }

        //Bind the DataTable.
        //gvStudentList.DataSource = dt;
        int noRows = dt.Rows.Count;
        StudentAccountingDataTableAdapters.fin_temp_balanceTableAdapter BALDATA = new StudentAccountingDataTableAdapters.fin_temp_balanceTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            try
            {
                BALDATA.Insert(dt.Rows[i]["RegistrationNo"].ToString(), dt.Rows[i]["Names"].ToString(), double.Parse(dt.Rows[i]["Balance"].ToString()), "Pending");
            }
            catch (Exception) { }
        }
        gvStudentList.DataBind();
        lbl_comment.Text = noRows+" Records Processed Successfully";
    }
    protected void cmdPickFile_Click(object sender, EventArgs e)
    {
        pop_uploader.ShowOnPageLoad = true;
    }
    protected void gvStudentList_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdCapture_Click(object sender, EventArgs e)
    {
        CoopERPDataTableAdapters.fin_ledgerTableAdapter LEDGER = new CoopERPDataTableAdapters.fin_ledgerTableAdapter();
        StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
        StudentAccountingDataTableAdapters.fin_temp_balanceTableAdapter BAL = new StudentAccountingDataTableAdapters.fin_temp_balanceTableAdapter();
        int noRows = gvStudentList.VisibleRowCount,counter=0;
        for (int i = 0; i < noRows; i++)
        {
            try
            {
                if (gvStudentList.Selection.IsRowSelected(i) && gvStudentList.GetRowValues(i, "capture_status").ToString() == "Pending" && 
                    STUD.GetRegNoByEntryNo(gvStudentList.GetRowValues(i, "regno").ToString()).ToString() != null)
                {
                    counter++;
                    LEDGER.fin_OpeningBalanceEntry(STUD.GetRegNoByEntryNo(gvStudentList.GetRowValues(i, "regno").ToString()).ToString(), "Student", "Opening Balance as at " + DateTime.Today.ToString("dd-MM-yyyy"),
                        double.Parse(gvStudentList.GetRowValues(i, "balance").ToString()), txtStartDate.Date, Session["username"].ToString(), "UGX");
                    BAL.UpdateCaptureStatus("Captured", gvStudentList.GetRowValues(i, "regno").ToString());
                    lbl_msgbox.Text = counter + " Balances Posted";
                }
            }
            catch (Exception ex)
            {
                //lbl_msgbox.Text = "Post Error! ["+ex.Message+"]";
                //break;
            }
        }
        gvStudentList.DataBind();
        pop_msgbox.ShowOnPageLoad = true;
       
    }
}
