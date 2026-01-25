using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_financials_BatchFeesStructure : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //Response.Write(Session["ItemCode"].ToString()+" ::"+ Session["sess"].ToString()+" ::"+  int.Parse(Session["yr"].ToString())+" ::"+  int.Parse(Session["semester"].ToString())+" ::"+ 
        //        int.Parse(Session["cyr"].ToString()));
        panel_batchfees.HeaderText = ("Batch Fees Structure for :: "+Session["ItemName"]).ToUpper();
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter STR = new StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter();
        try
        {
            STR.fin_CreateNewBatchStructure(int.Parse(Session["ItemCode"].ToString()), Session["sess"].ToString(), int.Parse(Session["yr"].ToString()), int.Parse(Session["semester"].ToString()),
                int.Parse(Session["cyr"].ToString()),double.Parse(Session["amt"].ToString()));
            lbl_msg.Text = "Structure Created Successfully";
            pop_messagebox.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Errror! [" + ex.Message + "]";
            pop_messagebox.ShowOnPageLoad = true;
        }
        gvClass.DataBind();
    }
    protected void chk_apply_all_CheckedChanged(object sender, EventArgs e)
    {
        if (chk_apply_all.Checked==true)
        {
            lbl_msg.Text = "No Records Selected";
            StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter STR = new StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter();
            int noRows = gvClass.VisibleRowCount,counter=0;
            for (int i = 0; i < noRows; i++)
            {
                if (gvClass.Selection.IsRowSelected(i))
                {
                    STR.UpdateAmount(decimal.Parse(gvClass.GetRowValues(gvClass.FocusedRowIndex, "amount").ToString()), int.Parse(gvClass.GetRowValues(i, "ID").ToString()));
                    counter++;
                }
            }
            gvClass.DataBind();
            lbl_msg.Text = "Amount [ "+gvClass.GetRowValues(gvClass.FocusedRowIndex, "amount").ToString()+" ] applied to "+counter+" selected records";
            chk_apply_all.Checked = false;
            pop_messagebox.ShowOnPageLoad = true;
        }
    }
}