using System;
using System.Collections.Generic;
using System.Web;
using admission_dataTableAdapters;

/// <summary>
/// Summary description for AdmissionLettersBLL
/// </summary>
/// 
[System.ComponentModel.DataObject]
public class AdmissionLettersBLL
{
    acad_admissionlettersTableAdapter letter = new acad_admissionlettersTableAdapter();

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public admission_data.acad_admissionlettersDataTable GetLetters(string acadyear,string intake)
    {
        return letter.Getadmissionletters(acadyear,intake);
    }
    public admission_data.acad_admissionlettersDataTable GetLetters(string acadyear)
    {
        return letter.GetAdmissionYearLetters(acadyear);
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddLetter(string letter_ref, string content, DateTime ldate, string prog_code, string sess, int campus, string acadyear, DateTime meet_date, string intake,string intro_text)
    {
        letter.acad_AdmissionLetterEditor(letter_ref, content, ldate, prog_code, sess, campus, acadyear, meet_date, intake, intro_text);
        return true;
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool UpdateLetter(string original_letter_ref, string content, DateTime ldate, string prog_code, string sess, int campus, string acadyear, DateTime meet_date, string intake
        , string intro_text)
    {
        letter.acad_AdmissionLetterEditor(original_letter_ref, content, ldate, prog_code, sess, campus, acadyear, meet_date, intake, intro_text);
        return true;
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteLetter(string original_letter_ref)
    {
        letter.acad_DeleteAdmissionLetter(original_letter_ref);
        return true;
    }
}