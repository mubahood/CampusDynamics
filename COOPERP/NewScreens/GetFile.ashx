<%@ WebHandler Language="C#" Class="NewScreens_GetFile" %>

using System;
using System.IO;
using System.Web;
using System.Web.SessionState;

public class NewScreens_GetFile : IHttpHandler, IReadOnlySessionState
{
    public bool IsReusable { get { return false; } }

    public void ProcessRequest(HttpContext ctx)
    {
        // Must be authenticated
        if (ctx.Session == null || ctx.Session["username"] == null)
        {
            ctx.Response.StatusCode = 403;
            ctx.Response.End();
            return;
        }

        // Sanitise filename — reject any path traversal
        string raw      = ctx.Request.QueryString["f"] ?? "";
        string filename = Path.GetFileName(raw);
        if (string.IsNullOrEmpty(filename) || filename != raw)
        {
            ctx.Response.StatusCode = 400;
            ctx.Response.End();
            return;
        }

        string folder   = GetUploadFolder(ctx);
        string fullPath = Path.Combine(folder, filename);

        if (!File.Exists(fullPath))
        {
            ctx.Response.StatusCode = 404;
            ctx.Response.End();
            return;
        }

        string ext = Path.GetExtension(filename).ToLower();
        ctx.Response.ContentType = MimeType(ext);

        // Cache privately for 30 days
        ctx.Response.Cache.SetCacheability(HttpCacheability.Private);
        ctx.Response.Cache.SetMaxAge(TimeSpan.FromDays(30));
        ctx.Response.Cache.SetLastModifiedFromFileDependencies();
        ctx.Response.AddFileDependency(fullPath);

        ctx.Response.TransmitFile(fullPath);
    }

    private static string GetUploadFolder(HttpContext ctx)
    {
        string adminRoot  = ctx.Server.MapPath("~/");
        string sharedRoot = Path.Combine(adminRoot, @"..\..\CampusDynamics_Portal\COOPERP\Support\Uploads\");
        string folder     = Path.GetFullPath(sharedRoot);
        if (Directory.Exists(folder)) return folder;

        // Fallback: local uploads inside admin app
        string local = Path.Combine(adminRoot, @"COOPERP\Support\Uploads\");
        Directory.CreateDirectory(local);
        return local;
    }

    private static string MimeType(string ext)
    {
        switch (ext)
        {
            case ".jpg":
            case ".jpeg": return "image/jpeg";
            case ".png":  return "image/png";
            case ".gif":  return "image/gif";
            case ".pdf":  return "application/pdf";
            case ".doc":  return "application/msword";
            case ".docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case ".txt":  return "text/plain; charset=utf-8";
            default:      return "application/octet-stream";
        }
    }
}
