using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Registry_PhotoUpload : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAttach_Click(object sender, EventArgs e)
    {
        uploadSmallImage("Photo");
    }
    public void uploadSmallImage(string ImageFormat)
    {
        imageManager im = new imageManager();
        Random num = new Random();
        int curImage = num.Next();
        LegacyDataTableAdapters.acad_student_legacyTableAdapter STUD = new LegacyDataTableAdapters.acad_student_legacyTableAdapter();

        if (txtFilePath.HasFile)
        {
            Stream ImagePath = txtFilePath.FileContent;
            int length = Convert.ToInt32(ImagePath.Length);
            byte[] origImageData = new byte[length];
            ImagePath.Read(origImageData, 0, length);
            if (ImageFormat == "Photo")
            {
                File.WriteAllBytes(Server.MapPath(string.Format("~/COOPERP/StudentInfo/photos/{0}.jpg", curImage)), im.MakeThumb(origImageData));
                STUD.UpdatePhoto(curImage + ".jpg", Session["reg"].ToString());
            }
            else
            {
                File.WriteAllBytes(Server.MapPath(string.Format("~/COOPERP/StudentInfo/signs/{0}.jpg", curImage)), im.MakeThumb(origImageData));
                //img.UpdateStudentSignature(RegNo, im.MakeSignatureThumb(origImageData));
            }
            lbl_comment.Text = "Attachment Complete";
        }
        else
        {
            lbl_comment.Text = "No Photo Specified";
        }
    }
}