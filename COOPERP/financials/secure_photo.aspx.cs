using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_financials_secure_photo : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAttach_Click(object sender, EventArgs e)
    {
        uploadSmallImage();
    }
    public void uploadSmallImage()
    {
        imageManager im = new imageManager();
        Random num = new Random();
        int curImage = num.Next();
        StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();

        if (txtFilePath.HasFile)
        {
            Stream ImagePath = txtFilePath.FileContent;
            int length = Convert.ToInt32(ImagePath.Length);
            byte[] origImageData = new byte[length];
            ImagePath.Read(origImageData, 0, length);
            if (File.Exists(Server.MapPath(string.Format("~/COOPERP/images/exam_card_background.jpg"))))
            {
                File.Delete(Server.MapPath(string.Format("~/COOPERP/images/exam_card_background.jpg")));
            }
            File.WriteAllBytes(Server.MapPath(string.Format("~/COOPERP/images/exam_card_background.jpg")), origImageData);
            lbl_comment.Text = "Attachment Complete";
        }
        else
        {
            lbl_comment.Text = "No Photo Specified";
        }
    }
}