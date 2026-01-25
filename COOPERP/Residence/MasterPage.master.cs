using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class OPAC_MasterPage : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
         {
             if (Session["otp"] == null)
             {
                 //Response.Redirect("~/MyApplications.aspx");
             }
         }
         catch (Exception)
         {
             //Response.Redirect("~/Default.aspx");
         }
        
        if (!IsPostBack)
        {

            try


            {

                lbl_footer.Text = string.Format("(c) {0} Newline Technologies Limited\n Support: hammshx@gmail.com | 256703502258", DateTime.Today.Year);
                lbl_date.Text = string.Format("Date: {0}", DateTime.Now.ToString("dddd, dd MMMM, yyyy"));
               
            }
            catch (Exception)
            {

            }
        }

        try
        {
            if (Session["username"] == null)
            {
                Response.Redirect("~/Default.aspx");
            }
        }
        catch (Exception)
        {
            Response.Redirect("~/Default.aspx");
        }

       
    }
    
}
