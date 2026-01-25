using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Registry_TranscriptFormatCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void gvMarksheetInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {

        pop_details.ContentUrl = "~/COOPERP/Registry/TranscriptFormatDetails.aspx?formatid=" + gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "ID") + "&progname=" + gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "details") + "&progid=" + gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "prog_id");
        pop_details.Width = 800;
        pop_details.Height = 500;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        pop_new_formats.ShowOnPageLoad = true;
    }
    protected void cmdAddNewSettings_Click(object sender, EventArgs e)
    {
        try
        {
            TranscriptSetupDataTableAdapters.acad_transcript_formatTableAdapter FORMATS = new TranscriptSetupDataTableAdapters.acad_transcript_formatTableAdapter();

            if (txt_all_progs.Checked == true)
            {
                int noItems = txtProg.Items.Count, counter = 0;
                try
                {
                    FORMATS.acad_BatchTranscriptFormats(txtStudySystem.Text);
                    lbl_comments.ForeColor = System.Drawing.Color.Blue;
                    lbl_comments.Text = "Settings List Created";
                }
                catch (Exception ex)
                {
                    lbl_comments.ForeColor = System.Drawing.Color.Red;
                    lbl_comments.Text = "Error! " + ex.Message;
                    //break;
                }
                gvMarksheetInfo.DataBind();
            }
            else
            {
                FORMATS.Insert(txtProg.Value.ToString(), txtProg.Value + " Transcript Format", DateTime.Today.Year.ToString(),
                    txtProg.Text + " Transcript Format", txtStudySystem.Text);
                gvMarksheetInfo.DataBind();
                lbl_comments.ForeColor = System.Drawing.Color.Blue;
                lbl_comments.Text = "Settings List Created";
            }
        }
        catch (Exception ex)
        {
            lbl_comments.ForeColor = System.Drawing.Color.Red;
            lbl_comments.Text = "Error! ["+ex.Message+"]";
        }
        
    }
}