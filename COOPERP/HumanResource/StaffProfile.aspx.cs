using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

public partial class COOPERP_HumanResource_StaffProfile : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
  
    protected void cmdAttach_Click(object sender, EventArgs e)
    {
        //Attach 
        uploadSmallImage(Session["empID"].ToString());
        gvStaffProfile.DataBind();

    }
    public void uploadSmallImage(String RegNo)
    {
        try
        {
            imageManager im = new imageManager();
            //admissions_and_classesTableAdapters.studentimagesTableAdapter img = new admissions_and_classesTableAdapters.studentimagesTableAdapter();
            if (txtFilePath.HasFile)
            {
                Stream ImagePath = txtFilePath.FileContent;
                int length = Convert.ToInt32(ImagePath.Length);
                byte[] origImageData = new byte[length];
                ImagePath.Read(origImageData, 0, length);
                File.WriteAllBytes(Server.MapPath(string.Format("~/COOPERP/staffimages/{0}_photo.jpg", RegNo)), im.MakeThumb(origImageData));
                //img.UpdateStudentImage(RegNo, im.MakeThumb(origImageData));

                lbl_comment.Text = "Attachment Complete.";
            }
            else
            {
                lbl_comment.Text = "No Photo Specified.";
            }
        }
        catch (Exception) { }
    }
    protected string GenerateImageUrl()
    {
        Random rnd = new Random();
        string res = String.Format("~/COOPERP/staffimages/{0}_photo.jpg?p={1}", Session["empID"], rnd.Next(10000));
        return res;
    }
}