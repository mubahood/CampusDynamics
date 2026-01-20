using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MobileDataTableAdapters;

public partial class COOPERP_Mobile_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string returnString = "-";
        if (Request.QueryString["DataFormat"] == "StudentBioData")
        {
            acad_StudentBioDataTableAdapter STUD = new acad_StudentBioDataTableAdapter();
            returnString = jsoncreator.TableToJSON(STUD.GetData(Request.QueryString["regno"]));
        }
        else if (Request.QueryString["DataFormat"] == "StudentSearch")
        {
            acad_StudentSearchTableAdapter STUD = new acad_StudentSearchTableAdapter();
            returnString = jsoncreator.TableToJSON(STUD.GetData(Request.QueryString["txt"]));
        }
        else if (Request.QueryString["DataFormat"] == "NewComplaint")
        {
            acad_results_complaintsTableAdapter COMP = new acad_results_complaintsTableAdapter();
            try
            {
                //acad CHAR(25),sems INT,title CHAR(65),details TEX
                COMP.acad_AddResultsComplaint(Request.QueryString["reg"], Request.QueryString["acad"], int.Parse(Request.QueryString["sem"]),
                    Request.QueryString["title"], Request.QueryString["details"]);
                returnString = "Complaint Registered. Check Later for Updates";

            }
            catch (Exception)
            {
                returnString = "Error! Please Check your complaint!";
            }
        }
        else if (Request.QueryString["DataFormat"] == "MyComplaints")
        {
            acad_results_complaintsTableAdapter COMP = new acad_results_complaintsTableAdapter();
            returnString = jsoncreator.TableToJSON(COMP.GetMyComplaints(Request.QueryString["reg"]));
        }

        Response.Write(returnString);

    }
}