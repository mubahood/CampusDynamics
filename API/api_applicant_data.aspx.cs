using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class API_api_applicant_data : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["apikey"] == "302021")
        {
            try
            {
                Random appno=new Random();
                string appID=appno.Next(10000,99999).ToString();
                admission_dataTableAdapters.acad_applicationsTableAdapter APP = new admission_dataTableAdapters.acad_applicationsTableAdapter();
                admission_dataTableAdapters.acad_applicant_choicesTableAdapter CHOICE = new admission_dataTableAdapters.acad_applicant_choicesTableAdapter();
                APP.Insert(appID, Request["st_name"], Request["gender"], Request["nationality"], "", "DIRECT", "", "", DateTime.Today.Year.ToString(),
                    DateTime.Parse(Request["bdate"]),Request["phone"], "", "", Request["email"], "SINGLE", "1", 0, "", Request["country"], "", "", "", "", "", "", 
                    "None", "", "", "", "", Request["city"], "", "","", 0, "-", Request["intake"], "-", "-", Request["disability"], 1, "Online");

                CHOICE.Insert(appID, 1, Request["progcode"], 0, Request["study_session"], "13");

                Response.Write("{\"Status\":\"1\",\"Message\":\"Applicant Data Capture Complete\",\"ApplicNo\":\""+appID+"\"}");

            }
            catch (Exception ex)
            {
                Response.Write("{\"Status\":\"0\",\"Message\":\"Data Capture Error! ("+ex.Message+")\",\"ApplicNo\":\"0\"}");
            }
        }
    }
}