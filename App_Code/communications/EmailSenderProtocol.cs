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
        get { return ConfigurationManager.AppSettings["MAIL_PASSWORD"] ?? ""; }
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

     public string SendMail(string senderEmail, string receiverEmail,string subjectText,string senderName, string message, string password)
    {
        try
        {
            if (receiverEmail.StartsWith("-")) receiverEmail = receiverEmail.TrimStart('-');
            var fromAddress = string.IsNullOrWhiteSpace(senderEmail) ? MailFromAddress : senderEmail;
            var toAddress = receiverEmail;
            // Always authenticate with the configured MAIL_USERNAME (the actual mailbox owner)
            string authUser = MailUsername;
            string authPass = string.IsNullOrWhiteSpace(password) ? MailPassword : password;
            string subject = subjectText;
            string body = message;
            var smtp = new System.Net.Mail.SmtpClient();
            {
                smtp.Host = MailHost;
                smtp.Port = MailPort;
                smtp.EnableSsl = MailSsl;
                smtp.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                smtp.Credentials = new NetworkCredential(authUser, authPass);
                smtp.Timeout = 20000;
            }
            smtp.Send(fromAddress, toAddress, subject, body);
            return "Email Sent Successfully";
        }
        catch(Exception ex)
        {
            return "Error! "+ex.Message;
        }

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
             //Fetching Email Body Text from EmailTemplate File.  

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