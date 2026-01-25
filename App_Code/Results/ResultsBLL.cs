using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ResultsDataTableAdapters;

/// <summary>
/// Summary description for ResultsBLL
/// </summary>
public class ResultsBLL
{
    string userName = HttpContext.Current.User.Identity.Name;
    QueriesTableAdapter QR = new QueriesTableAdapter();
	public string CaptureResults(string reg,string csid,string acad,int sem, int mark,int cyr ,string stat,int rid,string alt_csid, double prac_percent, double prac_mark, string examfromat)
    {
        if (HttpContext.Current.User.IsInRole("Dean"))
        {

            QR.acad_CaptureResults(userName, reg, csid, acad, sem, mark, cyr, stat, rid, alt_csid);
            if (examfromat == "With Practicals")
                QR.UpdatePracticalFailures(prac_percent, prac_mark, reg, csid);
            return "Results Capture Completed";
            
        }
        else
        {

            return "Authorisation Error! ONLY Deans Can Approve Results!";
        }
       
    }
}