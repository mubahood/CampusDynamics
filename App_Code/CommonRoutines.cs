using System;
using System.Collections.Generic;


public class CommonRoutines
{
    public static string DefaultAcadYear()
    {
        //If the Month is between january and July, The academic Year is 1 year back / Current Year
        if (DateTime.Today.Month >= 1 && DateTime.Today.Month <= 7)
        {
            return string.Format("{0}/{1}", DateTime.Now.Year, DateTime.Now.Year+1);
        }
        else
        {
            return string.Format("{0}/{1}", DateTime.Now.Year, DateTime.Now.Year + 1);
        }
    }

    public static string DefaultAdmissionYear()
    {
        //If the Month is between january and July, The academic Year is 1 year back / Current Year
        return string.Format("{0}/{1}", DateTime.Now.Year, DateTime.Now.Year + 1);
    }

    public static string DefaultGradYear()
    {
        //If the Month is between january and July, The academic Year is 2 years back / Current Year - 1
        if (DateTime.Today.Month >= 1 && DateTime.Today.Month <= 7)
        {
            return string.Format("{0}/{1}", DateTime.Now.Year - 2, DateTime.Now.Year - 1);
        }
        else
        {
            return string.Format("{0}/{1}", DateTime.Now.Year - 1, DateTime.Now.Year);
        }
    }
    public static string DefaultSemester()
    {
        //If the Month is between january and July, The academic Year is 2 years back / Current Year - 1
        if (DateTime.Today.Month >= 1 && DateTime.Today.Month <= 7)
        {
            return string.Format("{0}", 2);
        }
        else
        {
            return string.Format("{0}", 1);
        }
    }
    public static List<String> ReturnYears()
    {
        List<String> list = new List<String>();
        for (int i = -30; i <= 10; i++ )
            list.Add(DateTime.Now.AddYears(i).Year.ToString());

        return list;
    }
    public static List<String> ReturnAcademicYrs()
    {
        List<String> list = new List<String>();
        for (int i = -30; i <= 10; i++)
            list.Add(string.Format("{0}/{1}", DateTime.Now.AddYears(i).Year.ToString(), (DateTime.Now.AddYears(i).Year+1).ToString()));
        return list;
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

    public string InfoImage(string checkWork)
    {
        if (checkWork == "Error")
        {
            return "~/icons/exclamation-red.png";
        }
        else
        {
            return "~/icons/information-button.png";
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
}
