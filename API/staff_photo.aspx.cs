using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

public partial class staff_photo : System.Web.UI.Page
{
    public class ApiResponse
    {
        public bool success { get; set; }
        public string message { get; set; }
        public string filePath { get; set; }
        public string fileName { get; set; }
        public long fileSize { get; set; }
        public string uploadDate { get; set; }
        public string staffNo { get; set; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        Response.AppendHeader("Access-Control-Allow-Origin", "*");

        if (Request.HttpMethod == "OPTIONS")
        {
            Response.StatusCode = 200;
            Response.End();
            return;
        }

        try
        {
            if (Request.HttpMethod == "POST")
            {
                ProcessFileUpload();
            }
            else
            {
                SendResponse(false, "Only POST method allowed");
            }
        }
        catch (Exception ex)
        {
            SendResponse(false, "Server error: " + ex.Message);
        }
    }

    private void ProcessFileUpload()
    {
        if (Request.Files.Count == 0)
        {
            SendResponse(false, "No file received");
            return;
        }

        string staffNo = Request.Form["staff_no"] ?? Request.QueryString["staff_no"];
        if (string.IsNullOrEmpty(staffNo))
        {
            SendResponse(false, "Staff number is required");
            return;
        }

        staffNo = System.Text.RegularExpressions.Regex.Replace(staffNo, @"[^a-zA-Z0-9_-]", "");

        HttpPostedFile file = Request.Files[0];

        if (file.ContentLength == 0)
        {
            SendResponse(false, "Empty file received");
            return;
        }

        if (file.ContentLength > 5 * 1024 * 1024)
        {
            SendResponse(false, "File size cannot exceed 5MB");
            return;
        }

        string fileExtension = Path.GetExtension(file.FileName).ToLower();
        string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };

        if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
        {
            SendResponse(false, "Only image files are allowed");
            return;
        }

        string uploadFolder = "~/COOPERP/staffimages/";
        string serverPath = Server.MapPath(uploadFolder);

        if (!Directory.Exists(serverPath))
        {
            Directory.CreateDirectory(serverPath);
        }

        string safeFileName = staffNo + "_photo.jpg";
        string filePath = Path.Combine(serverPath, safeFileName);
        if (File.Exists(filePath))
        {
            File.Delete(filePath);
        }
        file.SaveAs(filePath);

        var response = new ApiResponse
        {
            success = true,
            message = "File uploaded successfully",
            fileName = safeFileName,
            filePath = "/COOPERP/staffimages/" + safeFileName,
            fileSize = file.ContentLength,
            uploadDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
            staffNo = staffNo
        };

        SendJsonResponse(response);
    }

    private void SendResponse(bool success, string message)
    {
        var response = new ApiResponse { success = success, message = message };
        SendJsonResponse(response);
    }

    private void SendJsonResponse(object data)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        string json = serializer.Serialize(data);
        Response.Write(json);
        Response.End();
    }
}