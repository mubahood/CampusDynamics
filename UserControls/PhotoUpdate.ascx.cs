using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

public partial class UserControls_PhotoUpdate : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdPhotoSave_Click(object sender, EventArgs e)
    {
        int memberID = int.Parse(Session["memberID"].ToString());
        uploadSmallImage(memberID);
        gvMembers.DataBind();
    }
    public void uploadSmallImage(int memberID)
    {
        /*imageManager im = new imageManager();
        SettingsFile Settings = new SettingsFile();
        CoopERPDataTableAdapters.mem_membershipTableAdapter img = new CoopERPDataTableAdapters.mem_membershipTableAdapter();
        if (txtFilePath.HasFile)
        {
            try
            {
                Stream ImagePath = txtFilePath.FileContent;
                int length = Convert.ToInt32(ImagePath.Length);
                byte[] origImageData = new byte[length];
                ImagePath.Read(origImageData, 0, length);
                if (rb_type.Value.ToString() == "Photo")
                {
                    img.mem_UpdatePhotoSign(memberID, im.MakeThumb(origImageData), rb_type.Value.ToString());
                    lbl_mgsbox.Text = "Photo Attached to Member No " + memberID;
                }
                else
                {
                    img.mem_UpdatePhotoSign(memberID, im.MakeSignatureThumb(origImageData), rb_type.Value.ToString());
                    lbl_mgsbox.Text = "Signature Attached to Member No " + memberID;
                }
                img_msg.ImageUrl = Settings.InfoImage("OK");
                lbl_mgsbox.ForeColor = Settings.InfoColor("OK");
                
            }
            catch (Exception)
            {
                img_msg.ImageUrl = Settings.InfoImage("Error");
                lbl_mgsbox.ForeColor = Settings.InfoColor("Error");
                lbl_mgsbox.Text = "Upload error on Member No "+memberID;
            }
            
        }
        else
        {
            img_msg.ImageUrl = Settings.InfoImage("Error");
            lbl_mgsbox.ForeColor = Settings.InfoColor("Error");
            lbl_mgsbox.Text = "No Image Specified";
        }*/
    }
    protected void cmdUpdatePhoto_Click(object sender, EventArgs e)
    {
        if (cmdUpdatePhoto.Text.Contains("Hide") == false)
        {
            rp_photoupdate.Visible = true;
            cmdUpdatePhoto.Text = "Hide Update Panel";
        }
        else
        {
            rp_photoupdate.Visible = false;
            cmdUpdatePhoto.Text = "Show Update Panel";
        }
    }
    protected void rb_type_SelectedIndexChanged(object sender, EventArgs e)
    {
        cmdPhotoSave.Text = "Upload " + rb_type.SelectedItem.Text;
    }
}