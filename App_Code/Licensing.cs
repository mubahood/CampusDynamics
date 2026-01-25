using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.IO;
using AccessControlTableAdapters;
//using PageLoader;

    public class Licensing
    {
       public static string SchoolName = "KASOKA DENTAL CLINIC";
       public static string PassCode = "kasoka";
       public static string LicenceComment;
       
       public string UpdateLicense(string LicenseCode)
       {
           string EndDate = LicenseCode;
           try
           {
               
               EndDate = encrypter.DecryptString(LicenseCode);
               fin_expdatesTableAdapter License = new fin_expdatesTableAdapter();
               License.UpdateLicense(EndDate,DateTime.Today);
               return "License Updated to end on "+EndDate;
           }
           catch(Exception ex)
           {
               return "Licensing Error!" + ex.Message;
           }
       }
       public static bool Settings()
       {
           string currentExpiry = "";
           fin_expdatesTableAdapter License = new fin_expdatesTableAdapter();
           try
           {
               DateTime EndDate = DateTime.Parse(License.MyCurrentExpDate().ToString());
               if (DateTime.Compare(EndDate, DateTime.Today) > 0)
               {
                   if (DateValidator() == true)
                   {
                       License.UpdateLastLogin(DateTime.Today);
                       return true;
                   }
                   else
                   {
                       LicenceComment = "CAUTION\nYOUR SYSTEM DATE HAS BEEN BACKDATED\nCORRECT IT AND TRY AGAIN";
                       return false;
                   }
               }
               else
               {
                   LicenceComment = "CAUTION\nYOUR LICENCE HAS EXPIRED\nENTER A VALID CODE TO RENEW";
                   return false;
               }
           }
           catch (Exception ex)
           {
               LicenceComment = "CAUTION\nLICENCE ERROR! \n" + ex.Message;
               return false;  
           }
       }
       public static bool DateValidator()
       {
          
               DateTime LastLoginDate;
               fin_expdatesTableAdapter License = new fin_expdatesTableAdapter();
               LastLoginDate = DateTime.Parse(License.MyLastLogin().ToString());
               //EndDate = DateTime.Parse(currentExpiry);
               if (DateTime.Compare(LastLoginDate, DateTime.Today) <= 0)
               {
                   return true;
               }
               else
               {
                   return false;
               }
       }
    }
