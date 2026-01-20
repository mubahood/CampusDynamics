using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using admission_dataTableAdapters;

/// <summary>
/// Summary description for ApplicationsBLL
/// </summary>
/// 

[System.ComponentModel.DataObject]
public class ApplicationsBLL
{
    private string userNm = HttpContext.Current.User.Identity.Name;
    acad_applicationsTableAdapter applics = new acad_applicationsTableAdapter();
    acad_applicant_choicesTableAdapter ch = new acad_applicant_choicesTableAdapter();
    acad_applicant_performanceTableAdapter per = new acad_applicant_performanceTableAdapter();
    acad_otherqualificationsTableAdapter qual = new acad_otherqualificationsTableAdapter();
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public admission_data.acad_applicationsDataTable GetApplicants(int entryyr, int stat, string progID, string intake)
    {
        return applics.GetApplicants(entryyr, stat, progID, intake);
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public admission_data.acad_applicant_choicesDataTable GetApplicantChoices(string stud_entry_no)
    {
        return ch.Get_Applicantchoices(stud_entry_no);
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public admission_data.acad_applicant_performanceDataTable GetApplicantPerformance(string stud_entry_no)
    {
        return per.Get_ApplicantPerformance(stud_entry_no);
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public admission_data.acad_otherqualificationsDataTable GetApplicantOtherQualifications(string stud_entry_no)
    {
        return qual.Get_ApplicantOtherQualifications(stud_entry_no);
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddApplicant(string stud_entry_no, string stud_name, string stud_sex, string stud_nationality, string stud_religion,
         string stud_entry_method, string stud_sponsor, string sponsor_contact, string stud_entry_year, DateTime stud_birthdate,
         string stud_phone, string next_kin, string stud_phy_address, string stud_email, string stud_mar_stat, string stud_campus,
         ushort IsAccountTransfered, string spouse_name, string residence_country, string olevel_school, string alevel_school, string referee_name,
         string referee_contacts, string referee_comments, string letter_campus, string health_comments, string olevel_index,
         string alevel_index, string spouse_contacts, string post_box, string home_district, string stud_occupation, string kin_contacts,
         string kin_relationship, uint alevel_year, string stud_intake, string spouseOccupation, string title, string physicalDisability,string prog)
    {
        try
        {
            applics.Insert(stud_entry_no, stud_name, stud_sex, stud_nationality, stud_religion, stud_entry_method, stud_sponsor, sponsor_contact, stud_entry_year, stud_birthdate, stud_phone, next_kin, stud_phy_address, stud_email, stud_mar_stat,
                    stud_campus, IsAccountTransfered, spouse_name, residence_country, olevel_school, alevel_school, referee_name, referee_contacts, referee_comments, letter_campus,
                    health_comments, olevel_index, alevel_index, spouse_contacts, post_box, home_district, stud_occupation, kin_contacts, kin_relationship, alevel_year,
                    "", stud_intake, spouseOccupation, title, physicalDisability, userNm,prog);

            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddApplicantChoice(string stud_entry_no, uint choice, string prog_id, uint adm_status, string adm_session, string sub_comb)
    {
        try
        {
            ch.Insert(stud_entry_no, choice, prog_id, adm_status, adm_session, sub_comb);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public string AddApplicantSubjects(string studentryno, int noSubs, string lev)
    {
        try
        {
            per.Insert(studentryno, noSubs, lev);
            return noSubs + " Subjects Added.";
        }
        catch (Exception ex)
        {
            return "Error! " + ex.Message;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddOtherQualifications(string stud_entry_no, string q_qualif, string q_inst, string q_year, string q_class)
    {
        try
        {
            qual.Insert(stud_entry_no, q_qualif, q_inst, q_year, q_class);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool EditApplicantData(string original_stud_entry_no, string stud_name, string stud_sex, string stud_nationality, string stud_religion,
         string stud_entry_method, string stud_sponsor, string sponsor_contact, string stud_entry_year, DateTime stud_birthdate,
         string stud_phone, string next_kin, string stud_phy_address, string stud_email, string stud_mar_stat, string stud_campus,
         ushort IsAccountTransfered, string spouse_name, string residence_country, string olevel_school, string alevel_school, string referee_name,
         string referee_contacts, string referee_comments, string letter_campus, string health_comments, string olevel_index,
         string alevel_index, string spouse_contacts, string post_box, string home_district, string stud_occupation, string kin_contacts,
         string kin_relationship, uint alevel_year, string stud_intake, string spouseOccupation, string title, string physicalDisability)
    {
        try
        {
            applics.Update(original_stud_entry_no, stud_name, stud_sex, stud_nationality, stud_religion, stud_entry_method, stud_sponsor, sponsor_contact, stud_entry_year, stud_birthdate, stud_phone, next_kin, stud_phy_address, stud_email, stud_mar_stat,
                    stud_campus, IsAccountTransfered, spouse_name, residence_country, olevel_school, alevel_school, referee_name, referee_contacts, referee_comments, letter_campus,
                    health_comments, olevel_index, alevel_index, spouse_contacts, post_box, home_district, stud_occupation, kin_contacts, kin_relationship, alevel_year,
                    "", stud_intake, spouseOccupation, title, physicalDisability, userNm);

            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool EditApplicantChoice(string stud_entry_no, uint choice, string prog_id, uint adm_status, string adm_session, string sub_comb, uint original_ID)
    {
        try
        {
            ch.Update(stud_entry_no, choice, prog_id, adm_status, adm_session, sub_comb);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool EditApplicantResults(int original_ID, string sub_name, string grade)
    {
        try
        {
            per.Update(userNm, original_ID, sub_name, grade);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool UpdateOtherQualifications(string stud_entry_no, string q_qualif, string q_inst, string q_year, string q_class, uint original_ID)
    {
        try
        {
            qual.Update(stud_entry_no, q_qualif, q_inst, q_year, q_class, original_ID);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteApplicant(string original_stud_entry_no)
    {
        try
        {
            applics.Delete(original_stud_entry_no);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteApplicantChoice(uint original_ID)
    {
        try
        {
            ch.Delete(original_ID);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteApplicantResult(uint original_ID)
    {
        try
        {
            per.Delete(original_ID);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteQualifications(uint original_ID)
    {
        try
        {
            qual.Delete(original_ID);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}