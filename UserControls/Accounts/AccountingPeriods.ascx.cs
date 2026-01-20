using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;

public partial class UserControls_Accounts_ChartAccounts : System.Web.UI.UserControl
{
    ControlDefiners conts = new ControlDefiners();

    protected void Page_Load(object sender, EventArgs e)
    {
        // Check if user is in allowed roles
        if (!HttpContext.Current.User.IsInRole("Administrator") && !HttpContext.Current.User.IsInRole("Bursar"))
        {
            // Hide the control and optionally show a message
            this.Visible = false;  // hides entire control

            // Optionally, show a message or redirect
            lblError.Text = "Sorry. Only Administrator or Bursar can access this section.";
            lblError.ForeColor = System.Drawing.Color.Red;
            pop_error.HeaderText = "Access Denied";
            pop_error.ShowOnPageLoad = true;

            return; // stop further processing
        }
    }

    protected void cmdAdd_Click(object sender, EventArgs e)
    {
    }

    protected void txtData_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    protected void gvAccounts_BeforePerformDataSelect(object sender, EventArgs e)
    {
    }

    protected void gvHouseHold_CustomErrorText(object sender, ASPxGridViewCustomErrorTextEventArgs e)
    {
    }

    protected void gvAccounts_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
    }

    protected void cmdCategories_Click(object sender, EventArgs e)
    {
    }

    protected void cmdAddAccount_Click(object sender, EventArgs e)
    {
    }

    protected void gvMainAccounts_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
    {
    }

    protected void cmdAdd_Click1(object sender, EventArgs e)
    {
        // Only allow adding a new row if no other Open financial year exists
        bool hasOpen = false;
        for (int i = 0; i < gvFinacialPeriods.VisibleRowCount; i++)
        {
            object statusObj = gvFinacialPeriods.GetRowValues(i, "status");
            string status = "";
            if (statusObj != null && statusObj != DBNull.Value)
                status = statusObj.ToString();

            if (status == "Open")
            {
                hasOpen = true;
                break;
            }
        }

        if (hasOpen)
        {
            // Set the text of the existing label
            lblError.Text = "You must close the existing Open financial year before adding a new one.";
            lblError.ForeColor = System.Drawing.Color.Red;
            lblError.Font.Bold = true;
            // Set popup header
            pop_error.HeaderText = "Error";

            // Show the popup
            pop_error.ShowOnPageLoad = true;
        }
        else
        {
            gvFinacialPeriods.AddNewRow();
        }
    }

    protected void gvFinacialPeriods_CellEditorInitialize(object sender, ASPxGridViewEditorEventArgs e)
    {
        if (e.Column.FieldName == "finacial_Year")
        {
            ASPxComboBox combo = e.Editor as ASPxComboBox;
            if (combo != null)
            {
                combo.DataSource = CommonRoutines.ReturnAcademicYrs();
                combo.DataBind();
                combo.Text = CommonRoutines.DefaultAcadYear();
            }
        }
    }

    protected void gvFinacialPeriods_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        // Safely get the new status
        object statusObj = e.NewValues["status"];
        string newStatus = (statusObj != null && statusObj != DBNull.Value) ? statusObj.ToString() : string.Empty;

        // If trying to set status to Open
        if (newStatus == "Open")
        {
            // Check if there is already another Open financial year (excluding the row being updated)
            for (int i = 0; i < gvFinacialPeriods.VisibleRowCount; i++)
            {
                object idObj = gvFinacialPeriods.GetRowValues(i, "id");
                object statusExisting = gvFinacialPeriods.GetRowValues(i, "status");

                int existingId = idObj != null ? Convert.ToInt32(idObj) : 0;
                string existingStatus = "";
                if (statusExisting != null && statusExisting != DBNull.Value)
                    existingStatus = statusExisting.ToString();

                int updatingId = e.Keys["id"] != null ? Convert.ToInt32(e.Keys["id"]) : 0;

                if (existingStatus == "Open" && existingId != updatingId)
                {
                    e.Cancel = true;
                    gvFinacialPeriods.JSProperties["cpError"] = "Only one financial year can be Open at a time. Close the existing one first.";
                    return;
                }
            }
        }
    }
}
