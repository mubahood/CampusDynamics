using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HRMDataTableAdapters;
using DevExpress.Web;

public partial class UserControls_HumanResource_MonthlyDeductionAllowance : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvStaffList.DataBind();
    }
    protected void txtType_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvStaffList.DataBind();
    }
    protected void txtDeductionAllowanceName_DataBound(object sender, EventArgs e)
    {
        //txtDeductionAllowanceName.SelectedIndex = 0;
    }
    protected void cmdRefreshList_Click(object sender, EventArgs e)
    {
        try
        {
            hrm_monthly_ded_allowanceTableAdapter DedList = new hrm_monthly_ded_allowanceTableAdapter();
            DedList.GetSingleMonthlyDedAllowancesList(int.Parse(Session["pid"].ToString()), int.Parse(txtDeductionAllowanceName.Value.ToString()), txtType.Text, "Refresh",txtSchool.Text);
            gvStaffList.DataBind();
            lbl_pop.ForeColor = System.Drawing.Color.Blue;
            lbl_pop.Text = "Refresh Completed";
        }
        catch (Exception ex)
        {
            lbl_pop.ForeColor = System.Drawing.Color.Red;
            lbl_pop.Text = "Error!!"+ex.Message;
        }
        pop_checks.ShowOnPageLoad = true;
    }
    protected void txtDeductionAllowanceName_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvStaffList.DataBind();
    }
    protected void cmdSaveChanges_Click(object sender, EventArgs e)
    {
        int noRows = gvStaffList.VisibleRowCount, rid = 0;
        int Start = (gvStaffList.PageIndex) * gvStaffList.SettingsPager.PageSize;
        ControlDefiners cont = new ControlDefiners();
        HRMDataTableAdapters.hrm_monthly_ded_allowanceTableAdapter DS = new hrm_monthly_ded_allowanceTableAdapter();
        string comm;
            int End;
            if (gvStaffList.SettingsPager.PageSize > noRows)
            {
                End = noRows;
            }
            else if (gvStaffList.PageIndex < gvStaffList.PageCount - 1)
            {
                End = Start + gvStaffList.SettingsPager.PageSize;
            }
            else
            {
                End = Start + noRows - (gvStaffList.PageIndex) * gvStaffList.SettingsPager.PageSize;
            }

            comm = string.Format("No Updates Saved");
            for (int i = Start; i < End; i++)
            {
                try
                {
                    ASPxTextBox txtAMount = cont.DataASPXTextBoxDefiner("Amount", "txtAmount", gvStaffList, i);
                    DS.SaveChanges(decimal.Parse(txtAMount.Text),int.Parse(gvStaffList.GetRowValues(i,"ID").ToString()));
                    lbl_pop.ForeColor = System.Drawing.Color.Blue;
                    comm = "Updates Saved";
                }
                catch (Exception ex)
                {
                    lbl_pop.ForeColor = System.Drawing.Color.Red;
                    comm = "Error! "+ex.Message;
                }
            }
            gvStaffList.DataBind();
            lbl_pop.Text = comm;
            pop_checks.ShowOnPageLoad = true;
    }
}