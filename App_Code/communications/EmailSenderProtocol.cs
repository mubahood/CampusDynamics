using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Configuration;
/// <summary>
/// Summary description for EmailSenderProtocol
/// </summary>
public class EmailSenderProtocol
{
    private static string MailHost
    {
        get { return ConfigurationManager.AppSettings["MAIL_HOST"] ?? "smtp.gmail.com"; }
    }

    private static int MailPort
    {
        get
        {
            int port;
            if (int.TryParse(ConfigurationManager.AppSettings["MAIL_PORT"], out port)) return port;
            return 587;
        }
    }

    private static bool MailSsl
    {
        get
        {
            string enc = (ConfigurationManager.AppSettings["MAIL_ENCRYPTION"] ?? "ssl").Trim().ToLowerInvariant();
            return enc == "ssl" || enc == "tls" || enc == "true" || enc == "1";
        }
    }

    private static string MailUsername
    {
        get { return ConfigurationManager.AppSettings["MAIL_USERNAME"] ?? "info@mru.ac.ug"; }
    }

    private static string MailPassword
    {
        // Google App Passwords are displayed with spaces (e.g. "xxxx xxxx xxxx xxxx") but SMTP auth requires no spaces
        get { return (ConfigurationManager.AppSettings["MAIL_PASSWORD"] ?? "").Replace(" ", ""); }
    }

    private static string MailFromAddress
    {
        get { return ConfigurationManager.AppSettings["MAIL_FROM_ADDRESS"] ?? MailUsername; }
    }

    private static string MailFromName
    {
        get
        {
            string value = ConfigurationManager.AppSettings["MAIL_FROM_NAME"] ?? "Campus Dynamics";
            if (value == "${APP_NAME}")
                value = ConfigurationManager.AppSettings["APP_NAME"] ?? "Campus Dynamics";
            return value;
        }
    }

    /// <summary>
    /// Delivers a plain-text message via the edusaterp relay API.
    /// Returns true on success. Safe to call from any thread — no HttpContext needed.
    /// </summary>
    public static bool SendViaApi(string toEmail, string messageText, string sender = "Campus Dynamics")
    {
        try
        {
            string url = string.Format(
                "https://erp.edusaterp.com/api/SecureOTP/sendotp?msg={0}&email={1}&sender={2}",
                Uri.EscapeDataString(messageText),
                Uri.EscapeDataString(toEmail),
                Uri.EscapeDataString(sender));
            var req = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(url);
            req.Timeout = 18000;
            req.Method = "GET";
            using (var resp = (System.Net.HttpWebResponse)req.GetResponse())
            using (var reader = new System.IO.StreamReader(resp.GetResponseStream()))
            {
                return reader.ReadToEnd().IndexOf("successfully", StringComparison.OrdinalIgnoreCase) >= 0;
            }
        }
        catch { return false; }
    }

     public string SendMail(string senderEmail, string receiverEmail,string subjectText,string senderName, string message, string password)
    {
        if (receiverEmail != null && receiverEmail.StartsWith("-")) receiverEmail = receiverEmail.TrimStart('-');
        Exception smtpException = null;
        try
        {
            var fromAddress = string.IsNullOrWhiteSpace(senderEmail) ? MailFromAddress : senderEmail;
            string authUser = MailUsername;
            string authPass = string.IsNullOrWhiteSpace(password) ? MailPassword : password;
            var smtp = new System.Net.Mail.SmtpClient();
            smtp.Host = MailHost;
            smtp.Port = MailPort;
            smtp.EnableSsl = MailSsl;
            smtp.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
            smtp.Credentials = new NetworkCredential(authUser, authPass);
            smtp.Timeout = 20000;
            smtp.Send(fromAddress, receiverEmail, subjectText, message);
            return "Email Sent Successfully";
        }
        catch(Exception ex) { smtpException = ex; }

        // SMTP failed — fall back to API relay
        try
        {
            string apiMsg = string.IsNullOrWhiteSpace(subjectText)
                ? message
                : subjectText + ": " + message;
            if (SendViaApi(receiverEmail, apiMsg, string.IsNullOrWhiteSpace(senderName) ? MailFromName : senderName))
                return "Email Sent Successfully";
        }
        catch { }

        return "Error! " + (smtpException != null ? smtpException.Message : "Unknown error");
   }
     public static string SendAttachedMail(string receiverEmail, string subjectText, string senderName, string message, string attachmentpath)
     {
         try
         {
             if (receiverEmail.StartsWith("-")) receiverEmail = receiverEmail.TrimStart('-');
             var fromAddress = MailFromAddress;
             var toAddress = receiverEmail;
             string fromPassword = MailPassword;
             string subject = subjectText;
             string body = message;
             var smtp = new System.Net.Mail.SmtpClient();
             {
                 // Legacy SMTP (commented): smtp.gmail.com:587, SSL=true
                 smtp.Host = MailHost;
                 smtp.Port = MailPort;
                 smtp.EnableSsl = MailSsl;
                 smtp.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                 smtp.Credentials = new NetworkCredential(fromAddress, fromPassword);
                 smtp.Timeout = 20000;
             }
             MailMessage emailMessage = new MailMessage();
             emailMessage.Body = message;
             emailMessage.Subject = subject;
             string[] to = { receiverEmail }; foreach (var m in to) { emailMessage.To.Add(m); }
             emailMessage.BodyEncoding = UTF8Encoding.UTF8;
             emailMessage.DeliveryNotificationOptions = DeliveryNotificationOptions.OnFailure;
             emailMessage.From = new MailAddress(fromAddress, senderName);
             if (attachmentpath != "-")
             {
                 emailMessage.Attachments.Add(new Attachment(attachmentpath));
             }
             smtp.Send(emailMessage);
             return "Email Sent Successfully";
         }
         catch (Exception ex)
         {
             return "Error! " + ex.Message;
         }

     }
     public static string SendEnquiryMail(string receiverEmail, string subjectText, string senderName, string message)
     {
         try
         {
             if (receiverEmail.StartsWith("-")) receiverEmail = receiverEmail.TrimStart('-');
             var fromAddress = MailFromAddress;
             var toAddress = receiverEmail;
             string fromPassword = MailPassword;
             string subject = subjectText;
             string body = message;
             var smtp = new System.Net.Mail.SmtpClient();
             {
                 // Legacy SMTP (commented): smtp.gmail.com:587, SSL=true
                 smtp.Host = MailHost;
                 smtp.Port = MailPort;
                 smtp.EnableSsl = MailSsl;
                 smtp.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                 smtp.Credentials = new NetworkCredential(fromAddress, fromPassword);
                 //smtp.Timeout = 20000;
             }
             smtp.Send(fromAddress, toAddress, subject, body);
             return "Email Sent Successfully";
         }
         catch (Exception ex)
         {
             return "Error! " + ex.Message;
         }

     }
     public static string SendHtmlEmail(string message, string receipients, string subject,string sendername)
     {
         try
         {
             //Fetching Settings from WEB.CONFIG file.  
            // Legacy hardcoded values (commented):
            // string emailSender = "noreply@ciu.ac.ug";
            // string emailSenderPassword = "noreply@c1u";
            // string emailSenderHost = "smtp.gmail.com";
            // int emailSenderPort = Convert.ToInt16("587");
            // Boolean emailIsSSL = true;
            string emailSender = MailFromAddress;
            string emailSenderPassword = MailPassword;
            string emailSenderHost = MailHost;
            int emailSenderPort = MailPort;
            Boolean emailIsSSL = MailSsl;
             System.Net.ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(RemoteServerCertificateValidationCallback);

             if (receipients.StartsWith("-")) receipients = receipients.TrimStart('-');
             // Strip invisible/non-printable chars that break MailAddress (non-breaking spaces, \r, \n, etc.)
             var _sb = new System.Text.StringBuilder(receipients.Length);
             foreach (char c in receipients) if (c > 0x20 && c != 0xA0 && c != 0xFEFF) _sb.Append(c);
             receipients = _sb.ToString();
             if (string.IsNullOrEmpty(receipients) || !receipients.Contains("@"))
                 return "Email Error! [Invalid or empty recipient email address]";

             string MailText = message;

             //Base class for sending email  
             MailMessage _mailmsg = new MailMessage();

             //Make TRUE because our body text is html  
             _mailmsg.IsBodyHtml = true;

             //Set From Email ID  
             _mailmsg.From = new MailAddress(emailSender, sendername);

             //Set To Email ID  
             _mailmsg.To.Add(receipients);

             //Set Subject  
             _mailmsg.Subject = subject;

             //Set Body Text of Email   
             _mailmsg.Body = MailText;


             //Now set your SMTP   
             SmtpClient _smtp = new SmtpClient();

             //Set HOST server SMTP detail  
             _smtp.Host = emailSenderHost;

             //Set PORT number of SMTP  
             _smtp.Port = emailSenderPort;

             //Set SSL --> True / False  
             _smtp.EnableSsl = emailIsSSL;

             //Set Sender UserEmailID, Password  
             NetworkCredential _network = new NetworkCredential(emailSender, emailSenderPassword);
             _smtp.Credentials = _network;

             //Send Method will send your MailMessage create above.  
             _smtp.Send(_mailmsg);
             return "Email sent successfully";
         }
         catch (Exception ex)
         {
             return "Email Error! [" + ex.Message + "]";
         }
     }
     private static bool RemoteServerCertificateValidationCallback(object sender, System.Security.Cryptography.X509Certificates.X509Certificate certificate, System.Security.Cryptography.X509Certificates.X509Chain chain, System.Net.Security.SslPolicyErrors sslPolicyErrors)
     {
         //Console.WriteLine(certificate);
         return true;
     }
}