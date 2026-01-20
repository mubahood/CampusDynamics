using DevExpress.Spreadsheet;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_ExcellDataLoader : System.Web.UI.Page
{
    Worksheet worksheet;
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
    protected void cmdLoadData_Click(object sender, EventArgs e)
    {

        CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter STAT = new CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter();
        STAT.ClearTable(int.Parse(Session["RID"].ToString()));
        worksheet = ES_BankData.Document.Worksheets.ActiveWorksheet;
        int index = 1;
        string comm = "";
        string transtype, amt = "",transno="-",dates="",details="";
        while (worksheet.Cells["B" + index].Value.ToString() != "" && worksheet.Cells["B" + index].Value.ToString() != null)
        {
            try
            {
                
                if (worksheet.Cells["C" + index].Value.ToString() == "") transtype = "DR"; else transtype = "CR";
                if (worksheet.Cells["C" + index].Value.ToString() == "") amt = worksheet.Cells["D" + index].Value.ToString(); else amt = worksheet.Cells["C" + index].Value.ToString();
                transno=transno+" "+worksheet.Cells["A" + index].Value.ToString();
                dates=dates+" "+worksheet.Cells["A" + index].Value.ToString();
                details = details + " " + worksheet.Cells["B" + index].Value.ToString();
                if (amt != null)
                {
                    STAT.Insert(transno.Substring(0,10), dates.Substring(0,10), details,transtype, worksheet.Cells["E" + index].Value.ToString(), 0,uint.Parse(Session["RID"].ToString()), double.Parse(amt.Replace(",", "")));
                    dates = "";
                    transno = "";
                    details = "";
                    lbl_msgbox.Text = "Data Loading Completed. [" + index + " Rows Processed]";
                    
                }
            }
            catch (Exception ex) {
                lbl_msgbox.Text = "Error. [" + index + "] Trans No: " + transno; 

            }
            index++;
        }
        
        pop_msgbox.ShowOnPageLoad = true;
    }
}