using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Registry_TranscriptFormatDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        panel_setting_details.HeaderText = Request["progname"].ToUpper();
    }
    protected void addCUnits_Click(object sender, EventArgs e)
    {
        pop_new_formats.ShowOnPageLoad = true;
    }
    protected void cmdAddNewSettings_Click(object sender, EventArgs e)
    {
        TranscriptSetupDataTableAdapters.acad_transcript_format_detailTableAdapter DETAILS = new TranscriptSetupDataTableAdapters.acad_transcript_format_detailTableAdapter();
        lbl_comments.Text = "";
        if (txt_batch_cu.Checked)
        {
            DETAILS.acad_AddBatchTranscriptCourses(Request["progid"], int.Parse(Request["formatid"]));
            gvTranscriptDetails.DataBind();
            lbl_comments.ForeColor = System.Drawing.Color.Blue;
            lbl_comments.Text = "Courses Added Successfully";
        }
        else
        {
            try
            {
                DETAILS.Insert(uint.Parse(Request["formatid"]), txtCourseUnit.Value.ToString(), uint.Parse(txtSemester.Text), uint.Parse(txtYear.Text));
                gvTranscriptDetails.DataBind();
                lbl_comments.ForeColor = System.Drawing.Color.Blue;
                lbl_comments.Text = "Course Added Successfully";
            }
            catch (Exception) {
                lbl_comments.ForeColor = System.Drawing.Color.Red;
                lbl_comments.Text = "Error! Course Already Added";
            }
        }
    }
    protected void txt_batch_cu_CheckedChanged(object sender, EventArgs e)
    {
        if (txt_batch_cu.Checked)
        {
            txtCourseUnit.Enabled = false;
            txtSemester.Enabled = false;
            txtYear.Enabled = false;
        }
        else
        {
            txtCourseUnit.Enabled = true;
            txtSemester.Enabled = true;
            txtYear.Enabled = true;
        }
    }
    protected void gvTranscriptDetails_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}