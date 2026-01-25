using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Net;
using System.Text;

/// <summary>
/// Summary description for SMSSendingBLL
/// </summary>
public class SMSSendingBLL
{
    public string SMSSending(string Sender, string Message, string Contacts)
    {
        string senderusername = "ciu";
        string senderpassword = "51555";
        string responseValue = "-";
        string URL = string.Format("https://instantsms.eurosatgroup.com/API/autosender.aspx");

        try
        {
            string postData = string.Format("unm={1}&ps={2}&message={3}&receipients={4}", Sender, senderusername, senderpassword, (Message + " - By " + Sender), Contacts); ;
            byte[] byteArray = Encoding.UTF8.GetBytes(postData);

            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(URL);
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
            webRequest.Method = "POST";
            webRequest.ContentType = "application/x-www-form-urlencoded";
            webRequest.ContentLength = byteArray.Length;

            using (Stream webpageStream = webRequest.GetRequestStream())
            {
                webpageStream.Write(byteArray, 0, byteArray.Length);
            }

            using (HttpWebResponse webResponse = (HttpWebResponse)webRequest.GetResponse())
            {
                using (StreamReader reader = new StreamReader(webResponse.GetResponseStream()))
                {
                    responseValue = reader.ReadToEnd();
                }
            }
        }
        catch (Exception ex)
        {
            responseValue = "Error! [" + ex.Message + "]";
        }

        return responseValue;
    }
}