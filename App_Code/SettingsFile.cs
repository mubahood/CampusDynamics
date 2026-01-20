using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CoopERPDataTableAdapters;

/// <summary>
/// Summary description for SettingsFile
/// </summary>
public class SettingsFile
{
    public static string AppName = "Campus Dynamics Version 1.0";
    public static string CampusName = "MRU";
    public string InfoImage(string checkWork)
    {
        if (checkWork == "Error")
        {
            return "~/COOPERP/images/exclamation-red.png";
        }
        else
        {
            return "~/COOPERP/images/information-button.png";
        }
    }

    public System.Drawing.Color InfoColor(string checkWork)
    {
        if (checkWork == "Error")
        {
            return System.Drawing.Color.Red;
        }
        else
        {
            return System.Drawing.Color.Blue;
        }
    }

    public static List<String> ReturnYears()
    {
        List<String> list = new List<String>();
        for (int i = -20; i <= 20; i++)
            list.Add(DateTime.Now.AddYears(i).Year.ToString());

        return list;
    }
    public static List<String> ReturnAcademicYrs()
    {
        List<String> list = new List<String>();
        for (int i = -20; i <= 20; i++)
            list.Add(string.Format("{0}/{1}", DateTime.Now.AddYears(i).Year.ToString(), (DateTime.Now.AddYears(i).Year + 1).ToString()));
        return list;
    }
    public static String ReturnDefaultAcademicYr()
    {
        if (DateTime.Now.Month >= 8)
        {
            return string.Format("{0}/{1}", DateTime.Now.Year.ToString(), (DateTime.Now.Year + 1).ToString());
        }
        else
        {
            return string.Format("{0}/{1}", (DateTime.Now.Year).ToString(), (DateTime.Now.Year+1).ToString());
        }
    }
    public static String ReturnDefaultGraduationYr()
    {
            return string.Format("{0}/{1}", (DateTime.Now.Year-1).ToString(), (DateTime.Now.Year).ToString());

    }
    public static List<String> ReturnMonths()
    {
        List<String> list = new List<String>();

        list.Add("-");
        list.Add("JANUARY");
        list.Add("FEBRUARY");
        list.Add("MARCH");
        list.Add("APRIL");
        list.Add("MAY");
        list.Add("JUNE");
        list.Add("JULY");
        list.Add("AUGUST");
        list.Add("SEPTEMBER");
        list.Add("OCTOBER");
        list.Add("NOVEMBER");
        list.Add("DECEMBER");


        return list;
    }

    public static List<String> ReturnDays()
    {
        List<String> list = new List<String>();

        list.Add("MONDAY");
        list.Add("TUESDAY");
        list.Add("WEDNESDAY");
        list.Add("THURSDAY");
        list.Add("FRIDAY");
        list.Add("SATURDAY");
        list.Add("SUNDAY");
        return list;
    }

    public static string DefaultMonth()
    {
        if (DateTime.Today.Month == 1)
            return "JANUARY";
        else if (DateTime.Today.Month == 2)
            return "FEBRUARY";
        else if (DateTime.Today.Month == 3)
            return "MARCH";
        else if (DateTime.Today.Month == 4)
            return "APRIL";
        else if (DateTime.Today.Month == 5)
            return "MAY";
        else if (DateTime.Today.Month == 6)
            return "JUNE";
        else if (DateTime.Today.Month == 7)
            return "JULY";
        else if (DateTime.Today.Month == 8)
            return "AUGUST";
        else if (DateTime.Today.Month == 9)
            return "SEPTEMBER";
        else if (DateTime.Today.Month == 10)
            return "OCTOBER";
        else if (DateTime.Today.Month == 11)
            return "NOVEMBER";
        else
            return "DECEMBER";
    }
   
    public static string DefaultSemester()
    {
        if (DateTime.Today.Month >= 8)
        {
            return "1";
        }
        else
        {
            return "2";
        }
    }
}