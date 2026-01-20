using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_StudentInfo_StudentProfile : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAttach_Click(object sender, EventArgs e)
    {
        uploadSmallImage(Session["regno"].ToString(), "Photo");
        BioData1.DataBind();
    }
    protected void cmdAttachSign_Click(object sender, EventArgs e)
    {
        uploadSmallImage(Session["regno"].ToString(), "Sign");
        BioData1.DataBind();
    }
    public void uploadSmallImage(String RegNo, string ImageFormat)
    {
        imageManager im = new imageManager();
        Random num = new Random();
        int curImage=num.Next();
        StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
        
        if (txtFilePath.HasFile)
        {
            Stream ImagePath = txtFilePath.FileContent;
            int length = Convert.ToInt32(ImagePath.Length);
            byte[] origImageData = new byte[length];
            ImagePath.Read(origImageData, 0, length);
            if (ImageFormat == "Photo")
            {
                File.WriteAllBytes(Server.MapPath(string.Format("~/COOPERP/StudentInfo/photos/{0}.jpg", curImage)), im.MakeThumb(origImageData));
                STUD.UpdatePhoto(curImage+".jpg",RegNo);
            }
            else
            {
                File.WriteAllBytes(Server.MapPath(string.Format("~/COOPERP/StudentInfo/signs/{0}.jpg", curImage)), im.MakeThumb(origImageData));
                STUD.UpdateSign(curImage + ".jpg", RegNo);
            }
            lbl_comment.Text = "Attachment Complete";
        }
        else
        {
            lbl_comment.Text = "No Photo Specified";
        }
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {

        Session["Report"] = txtDoc.Value;
        //if (Session["myProgname"].ToString().Contains("FOUNDATION"))
        //{
            Session["reg"] = Session["regno"];
            Session["Report"] = "SFSS";
            Response.Redirect("~/COOPERP/XtraReports/Default.aspx");
        //}
        //else
        //{
        //    Response.Redirect("~/COOPERP/Results/Reports/PrintCentre.aspx");
        //    //Response.Write("progname: " + Session["myProgname"]);
        //}

    }

    protected void ASPxButton1_Click(object sender, EventArgs e)
    {
        if (txtNewRegNo.Text != "")
        {
            StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
            if (!string.IsNullOrEmpty(Session["regno"].ToString()))
            {
                STUD.acad_RegNoChange(Session["regno"].ToString(), txtNewRegNo.Text);
                lbl_comments.Text = "Number Changed from " + Session["regno"].ToString() + " to " + txtNewRegNo.Text;
            }
            else
            {
                lbl_comments.Text = "Error: Student Does not have an Old Reg No.";
            }
        }
        else
        {
            lbl_comments.Text = "Enter New Reg Number";
        }

        pop_messagebox.ShowOnPageLoad = true;
    }

    protected void gv_sponsorInfo_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void SponsorGridView1_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["reg_no"] = Session["regno"].ToString();
    }
    protected void NextofKinGridView1_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["reg_no"] = Session["regno"].ToString();
    }
    protected void OtherGridView1_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["reg_no"] = Session["regno"].ToString();
    }
}