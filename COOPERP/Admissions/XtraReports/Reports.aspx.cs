using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using admission_dataTableAdapters;

public partial class COOPERP_Admissions_XtraReports_Reports : System.Web.UI.Page
{
    acad_admissionlettersTableAdapter letter = new acad_admissionlettersTableAdapter();
    acad_GetAdmissionListingTableAdapter listing = new acad_GetAdmissionListingTableAdapter();
    acad_GetApplicationListsTableAdapter applic = new acad_GetApplicationListsTableAdapter();

    admission_data ds = new admission_data();
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            int reportNo = int.Parse(Session["Report"].ToString());
            if (reportNo == 0)
            {
                applic.Fill(ds.acad_GetApplicationLists, Session["entyear"].ToString(), Session["campus"].ToString(), Session["Sess"].ToString(), Session["intake"].ToString());
                ApplicationList applist = new ApplicationList();
                applist.DataSource = ds;
                rp_viewer.Report = applist;
            }
            else if (reportNo == 1)
            {
                letter.Fill_AdmissionDetails(ds.acad_admissionletters, Session["Letter"].ToString());
                listing.Fill(ds.acad_GetAdmissionListing, 1, Session["programme"].ToString(), Session["entyear"].ToString(), Session["Sess"].ToString(), Session["campus"].ToString(),
                    Session["intake"].ToString());
                AdmissionLetter admletter = new AdmissionLetter();
                admletter.DataSource = ds;
                rp_viewer.Report = admletter;
            }
            else if (reportNo == 3)
            {
                //Response.Write("Single Letter");
                letter.Fill_AdmissionDetails(ds.acad_admissionletters, Session["Letter"].ToString());
                listing.SingleAdmissionLetter(ds.acad_GetAdmissionListing, Session["entno"].ToString(), Session["prog"].ToString());
                AdmissionLetter admletter = new AdmissionLetter();
                admletter.DataSource = ds;
                rp_viewer.Report = admletter;
            }
            else if (reportNo == 2)
            {
                
                listing.Fill_Admissionlist(ds.acad_GetAdmissionListing,Session["programme"].ToString(), Session["entyear"].ToString(), Session["Sess"].ToString(), Session["campus"].ToString(),
                    Session["intake"].ToString());
                AdmissionList adm = new AdmissionList();
                adm.DataSource = ds;
                rp_viewer.Report = adm;
            }
            
        }
        catch (Exception ex)
        {
            lbl_response.Text = "ERROR! " + ex.Message;
        }
    }
}